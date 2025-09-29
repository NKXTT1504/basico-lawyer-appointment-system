import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_helper.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Dịch vụ'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 32 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Các dịch vụ pháp lý của chúng tôi',
              style: TextStyle(
                fontSize: isTablet ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 24),
            
            _buildServiceCard(
              context,
              icon: Icons.gavel,
              title: 'Tư vấn pháp lý',
              description: 'Tư vấn các vấn đề pháp lý dân sự, hình sự, hành chính',
            ),
            
            const SizedBox(height: 16),
            
            _buildServiceCard(
              context,
              icon: Icons.description,
              title: 'Soạn thảo hợp đồng',
              description: 'Soạn thảo các loại hợp đồng, văn bản pháp lý',
            ),
            
            const SizedBox(height: 16),
            
            _buildServiceCard(
              context,
              icon: Icons.people_outline,
              title: 'Đại diện pháp lý',
              description: 'Đại diện khách hàng tại tòa án, cơ quan nhà nước',
            ),
            
            const SizedBox(height: 16),
            
            _buildServiceCard(
              context,
              icon: Icons.family_restroom,
              title: 'Luật gia đình',
              description: 'Tư vấn về ly hôn, nuôi con, cấp dưỡng',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Row(
          children: [
            Container(
              width: isTablet ? 60 : 50,
              height: isTablet ? 60 : 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF1E3A8A),
                size: isTablet ? 32 : 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
