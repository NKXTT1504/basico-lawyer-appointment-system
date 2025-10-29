import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../lawyer/data/services/lawyer_api_service.dart';
import '../../data/models/service.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
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

  List<dynamic> _extractList(dynamic body) {
    if (body == null) return const [];
    if (body is List) return body;
    if (body is Map<String, dynamic>) {
      final possibleKeys = <String>[
        'result',
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
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E3A8A),
        elevation: 0.5,
        title: const Text('Dịch vụ', style: TextStyle(color: Colors.black)),
      ),
      body: _buildBody(isTablet),
    );
  }

  Widget _buildBody(bool isTablet) {
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

    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Các dịch vụ pháp lý của chúng tôi',
            style: TextStyle(
              fontSize: isTablet ? 26 : 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chọn dịch vụ phù hợp, xem mô tả chi tiết và đặt lịch với luật sư chỉ trong vài bước.',
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 20),

          // Services grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 2 : 1,
              childAspectRatio: isTablet ? 1.2 : 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _services.length,
            itemBuilder: (context, index) {
              final service = _services[index];
              return _buildServiceCard(context, service, isTablet);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
      BuildContext context, ServiceModel service, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: isTablet ? 50 : 40,
                  height: isTablet ? 50 : 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.gavel,
                    color: const Color(0xFF1E3A8A),
                    size: isTablet ? 24 : 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name ?? 'Dịch vụ pháp lý',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E3A8A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (service.specialization != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          service.specialization!,
                          style: TextStyle(
                            fontSize: isTablet ? 12 : 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Description
          if (service.description != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                service.description!,
                style: TextStyle(
                  fontSize: isTablet ? 13 : 12,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          const SizedBox(height: 16),

          // Price and duration (mock data)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Giá: 500k-800k',
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Thời lượng: 90 phút',
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _viewServiceDetail(context, service),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Tìm hiểu thêm',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                // Bỏ nút đặt lịch trực tiếp: yêu cầu xem chi tiết trước
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _viewServiceDetail(BuildContext context, ServiceModel service) {
    context.push('/service-detail', extra: {'service': service});
  }

  // Removed direct booking: flow requires viewing details first
}

// Service model centralized in features/services/data/models/service.dart
