import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/firebase/storage_image.dart';

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

  Widget _buildAvatar(String? avatar) {
    if (avatar == null || avatar.isEmpty) {
      return const CircleAvatar(
        radius: 48,
        child: Icon(Icons.person, size: 60),
      );
    }
    if (avatar.startsWith('http')) {
      return CircleAvatar(
        radius: 48,
        backgroundImage: NetworkImage(avatar),
      );
    }
    return CircleAvatar(
      radius: 48,
      backgroundColor: AppColors.primary.withOpacity(0.08),
      child: ClipOval(
        child: StorageImage(
            path: avatar, width: 96, height: 96, fit: BoxFit.cover),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.onBackground),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Text('Chi tiết luật sư'),
      ),
      backgroundColor: const Color(0xFFF6F7FB),
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
          final city = l['address'] ?? '';
          final years = (l['expYears'] ?? l['experienceYears'] ?? 0).toString();
          final avatar = (l['img'] ?? l['imageUrl'] ?? '').isNotEmpty
              ? (l['img'] ?? l['imageUrl'])
              : null;
          final spec = (l['specialization'] ?? l['spect'] ?? '').toString();
          final bio = (l['bio'] ?? '').toString();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFEAECEF)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildAvatar(avatar),
                      const SizedBox(height: 12),
                      Text(name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 22)),
                      const SizedBox(height: 6),
                      FutureBuilder<Map<String, dynamic>>(
                        future: _ratingFuture,
                        builder: (context, rshot) {
                          if (rshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2));
                          }
                          final avg = (rshot.data?['average'] ?? 0);
                          final cnt = (rshot.data?['count'] ?? 0).toString();
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star,
                                  color: Color(0xFFFFB300), size: 20),
                              const SizedBox(width: 4),
                              Text(
                                  '${avg is num ? avg.toStringAsFixed(1) : avg}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(width: 6),
                              Text('($cnt đánh giá)',
                                  style: const TextStyle(color: Colors.grey)),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (spec.isNotEmpty) _infoChip(Icons.gavel, spec),
                          if (city.toString().isNotEmpty)
                            _infoChip(
                                Icons.location_on_outlined, city.toString()),
                          _infoChip(Icons.badge, 'Kinh nghiệm: $years năm'),
                        ],
                      ),
                    ],
                  ),
                ),

                // Bio section
                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFEAECEF))),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Giới thiệu',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            Text(bio,
                                style: TextStyle(
                                    color: Colors.grey.shade800, height: 1.45)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
