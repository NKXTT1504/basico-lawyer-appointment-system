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
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: width * (isTablet ? 0.08 : 0.04),
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button row
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'CHI TIẾT DỊCH VỤ',
                    style: TextStyle(
                      fontSize: width * (isTablet ? 0.05 : 0.045),
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Header card
              Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Color(0xFFEAECEF)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: isTablet ? 56 : 48,
                        height: isTablet ? 56 : 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A8A).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child:
                            const Icon(Icons.gavel, color: Color(0xFF1E3A8A)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.name ?? 'Dịch vụ pháp lý',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (service.specialization != null)
                              Text(
                                service.specialization!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            if (service.description != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                service.description!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade800,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Sections
              _buildSection(
                title: 'Tổng quan dịch vụ',
                content: _buildServiceOverview(),
              ),
              const SizedBox(height: 20),
              _buildSection(
                title: 'Quy trình của chúng tôi',
                content: _buildProcessSteps(),
              ),
              const SizedBox(height: 20),
              _buildSection(
                title: 'Bạn sẽ nhận được gì',
                content: _buildBenefits(),
              ),

              const SizedBox(height: 20),

              // CTA card
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Color(0xFFEAECEF)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Sẵn sàng bắt đầu?',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Đặt lịch tư vấn với luật sư chuyên môn để thảo luận nhu cầu cụ thể của bạn.',
                        style: TextStyle(color: Colors.grey.shade700),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _contactUs(context),
                              child: const Text('Liên hệ với chúng tôi'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _bookConsultation(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A8A),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Đặt lịch tư vấn'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget content}) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFEAECEF)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
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
            color: Colors.grey.shade700,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Với nhiều năm kinh nghiệm trong lĩnh vực pháp lý, chúng tôi hiểu rõ những thách thức mà khách hàng gặp phải và luôn sẵn sàng hỗ trợ với tinh thần trách nhiệm cao nhất.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
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
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.circular(14),
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['title']!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step['description']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
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
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        benefit,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
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
