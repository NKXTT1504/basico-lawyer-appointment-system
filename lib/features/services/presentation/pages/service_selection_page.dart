import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../lawyer/data/services/lawyer_api_service.dart';
import '../../data/models/service.dart';
import '../../../../core/theme/app_colors.dart';
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isTablet = width > 600;

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * (isTablet ? 0.08 : 0.04),
                      vertical: height * 0.02,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPageTitle(width, isTablet),
                        SizedBox(height: height * 0.02),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 8),
                            itemCount: _services.length,
                            itemBuilder: (context, index) {
                              final service = _services[index];
                              return _buildServiceCard(service);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildPageTitle(double width, bool isTablet) {
    return Text(
      'DỊCH VỤ & LĨNH VỰC',
      style: TextStyle(
        fontSize: width * (isTablet ? 0.07 : 0.06),
        fontWeight: FontWeight.bold,
        color: AppColors.onSurface,
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: _loadServices, child: const Text('Thử lại')),
        ],
      ),
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
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.gavel,
                    color: AppColors.primary,
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
                            color: AppColors.onSurfaceVariant,
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
