import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LawyerDetailPage extends StatefulWidget {
  final String lawyerId;
  const LawyerDetailPage({super.key, required this.lawyerId});

  @override
  State<LawyerDetailPage> createState() => _LawyerDetailPageState();
}

class _LawyerDetailPageState extends State<LawyerDetailPage> {
  late Future<Map<String, dynamic>> _profileFuture;
  late Future<Map<String, dynamic>> _ratingFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = fetchLawyerProfile(widget.lawyerId);
    _ratingFuture = fetchLawyerRating(widget.lawyerId);
  }

  // API: /api/Lawyer/GetProfileById/{id} (swagger Lawyers API v1)
  Future<Map<String, dynamic>> fetchLawyerProfile(String lawyerId) async {
    final uri = Uri.parse(
        'https://localhost:5000/api/lawyers/api/Lawyer/GetProfileById/$lawyerId');
    final res = await http.get(uri, headers: {'Accept': 'application/json'});
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final result = data['result'] ?? data;

      // Try to fetch fullName from User API if not in profile
      Map<String, dynamic> profile = Map<String, dynamic>.from(result);
      final userId = profile['userId']?.toString() ??
          profile['user']?['id']?.toString() ??
          profile['User']?['Id']?.toString();

      // If we don't have fullName in profile, fetch from User API
      bool hasFullName = profile['user']?['fullName'] != null ||
          profile['User']?['FullName'] != null ||
          profile['fullName'] != null ||
          profile['name'] != null;

      if (userId != null && !hasFullName) {
        try {
          final userUri =
              Uri.parse('https://localhost:5000/api/users/api/User/$userId');
          final userRes =
              await http.get(userUri, headers: {'Accept': 'application/json'});
          if (userRes.statusCode == 200) {
            final userData = json.decode(userRes.body);
            final userResult = userData['result'] ?? userData;
            if (userResult is Map && userResult['fullName'] != null) {
              // Ensure user object exists in profile
              if (profile['user'] == null) {
                profile['user'] = {};
              }
              if (profile['user'] is! Map) {
                profile['user'] = {};
              }
              profile['user']['fullName'] = userResult['fullName'];
            }
          }
        } catch (e) {
          print('Warning: Could not fetch user fullName: $e');
        }
      }

      return profile;
    }
    throw Exception('Không lấy được thông tin luật sư');
  }

  // API: /api/users/api/Review/lawyer/{lawyerId} (Users API v1)
  Future<Map<String, dynamic>> fetchLawyerRating(String lawyerId) async {
    try {
      final uri = Uri.parse(
          'https://localhost:5000/api/users/api/Review/lawyer/$lawyerId');
      final res = await http.get(uri, headers: {'Accept': 'application/json'});
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data is List && data.isNotEmpty) {
          final list = data.where((e) => e['rating'] != null).toList();
          if (list.isNotEmpty) {
            final avg = list.fold(
                    0.0, (double a, b) => a + (b['rating'] as num).toDouble()) /
                list.length;
            return {'average': avg, 'count': list.length};
          }
        }
      }
    } catch (_) {}
    return {'average': 0, 'count': 0};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết luật sư')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Lỗi: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có dữ liệu'));
          }
          final l = snapshot.data!;
          // Try to get fullName from nested user object first
          String? fullNameFromUser;
          if (l['user'] is Map) {
            fullNameFromUser =
                (l['user']['fullName'] ?? l['user']['name'])?.toString();
          } else if (l['User'] is Map) {
            fullNameFromUser = (l['User']['FullName'] ??
                    l['User']['Name'] ??
                    l['User']['fullName'] ??
                    l['User']['name'])
                ?.toString();
          }
          final String name = fullNameFromUser?.isNotEmpty == true
              ? fullNameFromUser!
              : (l['name'] ?? l['fullName'] ?? 'Luật sư')?.toString() ??
                  'Luật sư';
          final city = l['description'] ?? (l['address'] ?? '');
          final years = (l['expYears'] ?? l['experienceYears'] ?? 0).toString();
          final avatar = (l['img'] ?? l['imageUrl'] ?? '').isNotEmpty
              ? (l['img'] ?? l['imageUrl'])
              : null;
          final spec = l['specialization'] ?? l['spect'] ?? '';
          final bio = l['bio'] ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage:
                      (avatar != null) ? NetworkImage(avatar) : null,
                  child: avatar == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 22)),
                const SizedBox(height: 8),
                FutureBuilder<Map<String, dynamic>>(
                  future: _ratingFuture,
                  builder: (context, rshot) {
                    if (rshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2));
                    } else if (rshot.hasError) {
                      return const Text('-');
                    }
                    final avg = (rshot.data?['average'] ?? 0);
                    final cnt = (rshot.data?['count'] ?? 0).toString();
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        Text('${avg is num ? avg.toStringAsFixed(1) : avg}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        Text('($cnt đánh giá)',
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text('$spec', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 6),
                Text('$city', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.badge, size: 20),
                    const SizedBox(width: 6),
                    Text('Kinh nghiệm: $years năm'),
                  ],
                ),
                const SizedBox(height: 14),
                if (bio.isNotEmpty)
                  Card(
                    elevation: 0,
                    color: Colors.blue[50],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(bio),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
