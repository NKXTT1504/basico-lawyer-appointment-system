import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_helper.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

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
      body: SingleChildScrollView(
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
            _buildServiceDetail(
              context,
              icon: Icons.gavel,
              title: 'Tư vấn pháp lý',
              bullets: const [
                'Đánh giá nhanh vấn đề của bạn và đề xuất hướng xử lý',
                'Tư vấn dân sự, hình sự, hành chính, doanh nghiệp',
                'Tổng hợp tài liệu và cung cấp báo giá rõ ràng',
              ],
              cta: 'Tư vấn ngay',
            ),
            const SizedBox(height: 16),
            _buildServiceDetail(
              context,
              icon: Icons.description,
              title: 'Soạn thảo hợp đồng',
              bullets: const [
                'Soạn thảo hợp đồng mua bán, lao động, dịch vụ…',
                'Rà soát điều khoản rủi ro và bảo vệ quyền lợi',
                'Tùy chỉnh theo nhu cầu và mô hình kinh doanh',
              ],
              cta: 'Yêu cầu báo giá',
            ),
            const SizedBox(height: 16),
            _buildServiceDetail(
              context,
              icon: Icons.people_outline,
              title: 'Đại diện pháp lý',
              bullets: const [
                'Đại diện làm việc với cơ quan nhà nước, đối tác',
                'Tham gia tố tụng và bảo vệ quyền lợi hợp pháp',
                'Báo cáo tiến độ minh bạch theo tuần',
              ],
              cta: 'Liên hệ luật sư',
            ),
            const SizedBox(height: 16),
            _buildServiceDetail(
              context,
              icon: Icons.family_restroom,
              title: 'Luật gia đình',
              bullets: const [
                'Tư vấn ly hôn, nuôi con, cấp dưỡng, chia tài sản',
                'Hỗ trợ thủ tục nhanh gọn, bảo mật thông tin',
                'Đồng hành xuyên suốt quá trình giải quyết',
              ],
              cta: 'Đặt lịch tư vấn',
            ),
          ],
        ),
      ),
    );
  }

  // legacy card variant removed in favor of detailed sections

  Widget _buildServiceDetail(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<String> bullets,
    required String cta,
  }) {
    final isTablet = ResponsiveHelper.isTablet(context);
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
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isTablet ? 60 : 50,
                height: isTablet ? 60 : 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon,
                    color: const Color(0xFF1E3A8A), size: isTablet ? 32 : 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E3A8A))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...bullets.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  '),
                    Expanded(
                        child:
                            Text(b, style: TextStyle(color: Colors.grey[700]))),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () {
                // Could navigate to lawyers list to book
                Navigator.of(context).pushNamed('/lawyers');
              },
              child: Text(cta),
            ),
          )
        ],
      ),
    );
  }
}
