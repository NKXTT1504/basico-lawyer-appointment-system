import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/service.dart';

class ServiceDetailPage extends StatelessWidget {
  final ServiceModel service;

  const ServiceDetailPage({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết dịch vụ'),
        backgroundColor: Colors.blue[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue[800]!,
                    Colors.blue[600]!,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.gavel,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.name ?? 'Dịch vụ pháp lý',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              service.specialization ?? 'Chuyên môn pháp lý',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    service.description ??
                        'Dịch vụ tư vấn pháp lý chuyên nghiệp',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Service details
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service overview
                  _buildSection(
                    title: 'Tổng quan dịch vụ',
                    content: _buildServiceOverview(),
                  ),

                  const SizedBox(height: 32),

                  // Process steps
                  _buildSection(
                    title: 'Quy trình của chúng tôi',
                    content: _buildProcessSteps(),
                  ),

                  const SizedBox(height: 32),

                  // Benefits
                  _buildSection(
                    title: 'Bạn sẽ nhận được gì',
                    content: _buildBenefits(),
                  ),
                ],
              ),
            ),

            // CTA Section
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    'Sẵn sàng bắt đầu?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Đặt lịch tư vấn với luật sư chuyên môn để thảo luận nhu cầu cụ thể của bạn.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _contactUs(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.blue[600]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Liên hệ với chúng tôi'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _bookConsultation(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Đặt lịch tư vấn'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildServiceOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chúng tôi cung cấp dịch vụ tư vấn pháp lý chuyên nghiệp với đội ngũ luật sư giàu kinh nghiệm. Chúng tôi cam kết mang đến giải pháp pháp lý tối ưu nhất cho khách hàng.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Với nhiều năm kinh nghiệm trong lĩnh vực pháp lý, chúng tôi hiểu rõ những thách thức mà khách hàng gặp phải và luôn sẵn sàng hỗ trợ với tinh thần trách nhiệm cao nhất.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildProcessSteps() {
    final steps = [
      {
        'title': 'Tư vấn ban đầu',
        'description':
            'Gặp gỡ luật sư của chúng tôi để thảo luận về nhu cầu và mục tiêu của bạn.',
      },
      {
        'title': 'Phân tích vụ việc',
        'description':
            'Luật sư sẽ phân tích kỹ lưỡng vụ việc và xây dựng chiến lược cụ thể.',
      },
      {
        'title': 'Thực hiện giải pháp',
        'description':
            'Triển khai các biện pháp pháp lý phù hợp để bảo vệ quyền lợi của bạn.',
      },
      {
        'title': 'Theo dõi và hỗ trợ',
        'description':
            'Tiếp tục hỗ trợ và tư vấn trong suốt quá trình thực hiện.',
      },
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['title']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step['description']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBenefits() {
    final benefits = [
      'Tư vấn toàn diện và chuyên sâu',
      'Giải pháp cá nhân hóa theo nhu cầu',
      'Luật sư có chuyên môn cao',
      'Hỗ trợ 24/7 trong quá trình thực hiện',
      'Bảo mật thông tin tuyệt đối',
    ];

    return Column(
      children: benefits
          .map((benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[600],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        benefit,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  void _contactUs(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chức năng liên hệ sẽ được triển khai sớm'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _bookConsultation(BuildContext context) {
    // Chuyển đến trang chọn lĩnh vực và dịch vụ
    context.push('/service-field-selection', extra: {
      'service': service,
    });
  }
}

/* Service model moved to features/services/data/models/service.dart */
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
