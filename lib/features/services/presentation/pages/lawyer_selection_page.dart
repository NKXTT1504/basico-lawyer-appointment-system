import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../lawyer/data/services/lawyer_api_service.dart';
import '../../../../core/network/api_services.dart';

class LawyerSelectionPage extends StatefulWidget {
  final List<String> services;
  final String? field;

  const LawyerSelectionPage({
    super.key,
    required this.services,
    this.field,
  });

  @override
  State<LawyerSelectionPage> createState() => _LawyerSelectionPageState();
}

class _LawyerSelectionPageState extends State<LawyerSelectionPage> {
  List<Lawyer> _lawyers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLawyers();
  }

  Future<void> _loadLawyers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // BƯỚC 1: Fetch lawyers từ Lawyer API
      final response = await LawyerApiService.getLawyers();
      if (response.statusCode == 200) {
        final List<dynamic> data = _extractList(response.data);

        // BƯỚC 2: Fetch users từ User API để lấy fullName
        Map<String, String> userFullNameMap = {};
        try {
          final usersResponse = await ApiServices.usersGet('/api/User');
          if (usersResponse.statusCode == 200) {
            final usersData = usersResponse.data;
            List<dynamic> usersList = [];

            if (usersData is List) {
              usersList = usersData;
            } else if (usersData is Map<String, dynamic>) {
              final result = usersData['result'] ?? usersData['data'];
              if (result is List) {
                usersList = result;
              }
            }

            // Map userId -> fullName
            for (var user in usersList) {
              if (user is Map<String, dynamic>) {
                final userId = user['id']?.toString();
                final fullName = user['fullName']?.toString();
                if (userId != null && fullName != null && fullName.isNotEmpty) {
                  userFullNameMap[userId] = fullName;
                }
              }
            }
          }
        } catch (e) {
          print('Warning: Could not fetch users for fullName: $e');
        }

        // BƯỚC 3: Enrich lawyers với fullName từ users
        final allLawyers = data.map((json) {
          final jsonMap = _asMap(json);

          // Try to get userId from lawyer profile
          final userId = jsonMap['userId']?.toString() ??
              jsonMap['user']?['id']?.toString() ??
              jsonMap['User']?['Id']?.toString() ??
              jsonMap['User']?['id']?.toString();

          // If we have userId and fullName from users map, enrich the json
          if (userId != null && userFullNameMap.containsKey(userId)) {
            // Ensure user object exists in json
            if (jsonMap['user'] == null) {
              jsonMap['user'] = <String, dynamic>{};
            }
            if (jsonMap['user'] is! Map) {
              jsonMap['user'] = <String, dynamic>{};
            }
            (jsonMap['user'] as Map<String, dynamic>)['fullName'] =
                userFullNameMap[userId];
          }

          return Lawyer.fromJson(jsonMap);
        }).toList();

        // Lọc luật sư theo lĩnh vực hoặc các dịch vụ đã chọn
        final selectedServiceNames =
            widget.services.map((e) => e.toLowerCase()).toList();
        final selectedField = widget.field?.toLowerCase();
        final filteredLawyers = allLawyers.where((lawyer) {
          final spec = (lawyer.specialization ?? '').toLowerCase();
          final matchField = selectedField == null || selectedField.isEmpty
              ? false
              : spec.contains(selectedField) || selectedField.contains(spec);
          final matchAnyService = selectedServiceNames.any(
              (s) => s.isNotEmpty && (spec.contains(s) || s.contains(spec)));
          return matchField || matchAnyService;
        }).toList();

        // Sắp xếp lại filteredLawyers dựa trên số dịch vụ phù hợp nhất
        filteredLawyers.sort((a, b) {
          int aScore = 0;
          int bScore = 0;

          final aSpec = (a.specialization ?? '').toLowerCase();
          final bSpec = (b.specialization ?? '').toLowerCase();

          for (final s in selectedServiceNames) {
            if (s.isNotEmpty && aSpec.contains(s)) aScore++;
            if (s.isNotEmpty && bSpec.contains(s)) bScore++;
          }
          if (selectedField != null && selectedField.isNotEmpty) {
            if (aSpec.contains(selectedField)) aScore++;
            if (bSpec.contains(selectedField)) bScore++;
          }
          return bScore.compareTo(aScore);
        });
        final topLawyers = filteredLawyers.take(3).toList();

        setState(() {
          _lawyers = topLawyers;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Lỗi tải danh sách luật sư: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi tải danh sách luật sư: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Luật sư - ${widget.field ?? (widget.services.isNotEmpty ? widget.services.first : 'Dịch vụ')}'),
        backgroundColor: Colors.blue[50],
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLawyers,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_lawyers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy luật sư phù hợp cho dịch vụ này',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Quay lại'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _lawyers.length,
      itemBuilder: (context, index) {
        final lawyer = _lawyers[index];
        return _buildLawyerCard(lawyer);
      },
    );
  }

  List<dynamic> _extractList(dynamic body) {
    if (body == null) return const [];
    if (body is List) return body;
    if (body is Map<String, dynamic>) {
      for (final k in [
        'result', // API trả về {"isSuccess": true, "result": [...]}
        'data',
        'items',
        'results',
        'value',
        r'$values',
        'records',
        'lawyers'
      ]) {
        final v = body[k];
        if (v is List) return v;
      }
      for (final v in body.values) {
        if (v is List) return v;
      }
    }
    return const [];
  }

  Map<String, dynamic> _asMap(dynamic e) {
    if (e is Map<String, dynamic>) return e;
    if (e is Map) return e.map((k, v) => MapEntry(k.toString(), v));
    return <String, dynamic>{};
  }

  Widget _buildLawyerCard(Lawyer lawyer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue[100],
                  backgroundImage: lawyer.avatarUrl != null
                      ? NetworkImage(lawyer.avatarUrl!)
                      : null,
                  child: lawyer.avatarUrl == null
                      ? Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.blue[600],
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lawyer.name ?? 'Luật sư',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (lawyer.specialization != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          lawyer.specialization!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (lawyer.experience != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${lawyer.experience} năm kinh nghiệm',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (lawyer.rating != null) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.orange[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lawyer.rating!.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            if (lawyer.description != null) ...[
              const SizedBox(height: 12),
              Text(
                lawyer.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewProfile(lawyer),
                    icon: const Icon(Icons.info_outline),
                    label: const Text('Xem hồ sơ'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _bookAppointment(lawyer),
                    icon: const Icon(Icons.schedule),
                    label: const Text('Đặt lịch'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _viewProfile(Lawyer lawyer) {
    // TODO: Implement view lawyer profile
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Xem hồ sơ ${lawyer.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _bookAppointment(Lawyer lawyer) {
    // Điều hướng tới chọn ngày/giờ, truyền danh sách dịch vụ đã chọn
    context.push('/book-appointment/${lawyer.id}', extra: {
      'lawyerName': lawyer.name ?? 'Luật sư',
      'services': widget.services,
    });
  }

  // legacy booking bottom sheet removed in favor of direct navigation to booking page
}

// Service model centralized in features/services/data/models/service.dart

class Lawyer {
  final String? id;
  final String? name;
  final String? specialization;
  final String? description;
  final String? avatarUrl;
  final int? experience;
  final double? rating;

  Lawyer({
    this.id,
    this.name,
    this.specialization,
    this.description,
    this.avatarUrl,
    this.experience,
    this.rating,
  });

  factory Lawyer.fromJson(Map<String, dynamic> json) {
    // Try to get fullName from nested user object first
    String? fullNameFromUser;
    if (json['user'] is Map) {
      fullNameFromUser = json['user']['fullName']?.toString() ??
          json['user']['name']?.toString();
    } else if (json['User'] is Map) {
      fullNameFromUser = json['User']['FullName']?.toString() ??
          json['User']['Name']?.toString() ??
          json['User']['fullName']?.toString() ??
          json['User']['name']?.toString();
    }

    return Lawyer(
      id: json['id']?.toString(),
      name: fullNameFromUser?.isNotEmpty == true
          ? fullNameFromUser
          : (json['name']?.toString() ??
              json['fullName']?.toString() ??
              'Luật sư'),
      specialization: json['specialization']?.toString(),
      description: json['description']?.toString(),
      avatarUrl: json['avatarUrl']?.toString() ?? json['img']?.toString(),
      experience: json['experience'] is int
          ? json['experience']
          : (json['expYears'] is int
              ? json['expYears']
              : int.tryParse(json['experience']?.toString() ??
                  json['expYears']?.toString() ??
                  '')),
      rating: json['rating'] is double
          ? json['rating']
          : double.tryParse(json['rating']?.toString() ?? ''),
    );
  }
}
