import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../lawyer/data/services/lawyer_api_service.dart';
import '../../data/models/service.dart';
// import removed: booking happens after viewing details

class ServiceSelectionPage extends StatefulWidget {
  const ServiceSelectionPage({super.key});

  @override
  State<ServiceSelectionPage> createState() => _ServiceSelectionPageState();
}

class _ServiceSelectionPageState extends State<ServiceSelectionPage> {
  List<ServiceModel> _services = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await LawyerApiService.getServices();
      if (response.statusCode == 200) {
        final List<dynamic> data = _extractList(response.data);
        setState(() {
          _services =
              data.map((e) => ServiceModel.fromJson(_asMap(e))).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Lỗi tải dịch vụ: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi tải dịch vụ: $e';
        _isLoading = false;
      });
    }
  }

  // --- Helpers to handle various API shapes ---
  List<dynamic> _extractList(dynamic body) {
    if (body == null) return const [];
    if (body is List) return body;
    if (body is Map<String, dynamic>) {
      // Common wrappers: data, items, results, value, $values (C#)
      final possibleKeys = <String>[
        'result', // API trả về {"isSuccess": true, "result": [...]}
        'data',
        'items',
        'results',
        'value',
        r'$values',
        'list',
        'services',
        'records'
      ];
      for (final key in possibleKeys) {
        final value = body[key];
        if (value is List) return value;
      }
      // Try to find the first list value anywhere
      for (final value in body.values) {
        if (value is List) return value;
      }
    }
    return const [];
  }

  Map<String, dynamic> _asMap(dynamic e) {
    if (e is Map<String, dynamic>) return e;
    if (e is Map) return e.map((k, v) => MapEntry(k.toString(), v));
    return <String, dynamic>{};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dịch vụ và lĩnh vực'),
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
              onPressed: _loadServices,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final service = _services[index];
        return _buildServiceCard(service);
      },
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.gavel,
                    color: Colors.blue[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name ?? 'Dịch vụ pháp lý',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (service.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          service.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () {
                  context.push('/service-detail', extra: {'service': service});
                },
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Tìm hiểu thêm'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Loại bỏ book trực tiếp: chỉ cho phép xem chi tiết trước rồi mới booking
}

/* Service model defined centrally. This legacy local class is removed. */
/*
class Service {
  final String? id;
  final String? name;
  final String? description;
  final String? specialization;

  Service({
    this.id,
    this.name,
    this.description,
    this.specialization,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    String? pickStr(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v != null && v.toString().isNotEmpty) return v.toString();
      }
      return null;
    }

    // Lấy specialization từ practiceArea nếu có
    String? specialization;
    if (json['practiceArea'] is Map<String, dynamic>) {
      final practiceArea = json['practiceArea'] as Map<String, dynamic>;
      specialization = practiceArea['name']?.toString();
    }

    return Service(
      id: pickStr(['id', 'serviceId', 'serviceID', 'Id', 'ServiceId']),
      name: pickStr(['name', 'serviceName', 'title', 'Name']),
      description: pickStr(['description', 'desc', 'Description']),
      specialization: specialization ??
          pickStr([
            'specialization',
            'specializationName',
            'category',
            'field',
            'domain',
            'type'
          ]),
    );
  }
}
*/

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
    String? pickStr(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v != null && v.toString().isNotEmpty) return v.toString();
      }
      return null;
    }

    int? pickInt(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v is int) return v;
        if (v is String) {
          final p = int.tryParse(v);
          if (p != null) return p;
        }
      }
      return null;
    }

    double? pickDouble(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v is double) return v;
        if (v is num) return v.toDouble();
        if (v is String) {
          final p = double.tryParse(v);
          if (p != null) return p;
        }
      }
      return null;
    }

    return Lawyer(
      id: pickStr(['id', 'lawyerId', 'Id', 'LawyerId', 'userId']),
      name: pickStr(['name', 'fullName', 'displayName', 'Name']),
      specialization: pickStr([
        'specialization',
        'specializationName',
        'service',
        'serviceName',
        'field',
        'domain'
      ]),
      description: pickStr(['description', 'bio', 'summary']),
      avatarUrl: pickStr(['avatarUrl', 'avatar', 'imageUrl', 'photoUrl']),
      experience: pickInt(['experience', 'yearsExperience', 'years']),
      rating: pickDouble(['rating', 'avgRating', 'averageRating']),
    );
  }
}

class ServiceLawyerSelectionSheet extends StatelessWidget {
  final String service;
  final List<Lawyer> lawyers;
  final Function(Lawyer) onLawyerSelected;

  const ServiceLawyerSelectionSheet({
    super.key,
    required this.service,
    required this.lawyers,
    required this.onLawyerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.person_search,
                color: Colors.blue[600],
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Chọn luật sư cho "$service"',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lawyers list
          Expanded(
            child: ListView.builder(
              itemCount: lawyers.length,
              itemBuilder: (context, index) {
                final lawyer = lawyers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: lawyer.avatarUrl != null
                          ? NetworkImage(lawyer.avatarUrl!)
                          : null,
                      child: lawyer.avatarUrl == null
                          ? Icon(Icons.person, color: Colors.blue[600])
                          : null,
                    ),
                    title: Text(lawyer.name ?? 'Luật sư'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (lawyer.specialization != null)
                          Text(lawyer.specialization!),
                        if (lawyer.rating != null)
                          Row(
                            children: [
                              Icon(Icons.star,
                                  size: 16, color: Colors.orange[600]),
                              const SizedBox(width: 4),
                              Text(lawyer.rating!.toStringAsFixed(1)),
                            ],
                          ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => onLawyerSelected(lawyer),
                      child: const Text('Chọn'),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
