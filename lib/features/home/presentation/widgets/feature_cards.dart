import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_helper.dart';

class FeatureCards extends StatelessWidget {
  const FeatureCards({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = ResponsiveHelper.getScreenWidth(context);
    final screenHeight = ResponsiveHelper.getScreenHeight(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context, 
        mobile: screenWidth * 0.05, 
        tablet: screenWidth * 0.06, 
        desktop: screenWidth * 0.08
      )),
      child: ResponsiveHelper.getResponsiveLayout(context, 
        mobile: Column(
          children: [
            _buildFeatureCard(
              context,
              'Luật sư giàu kinh nghiệm',
              'Luật sư của chúng tôi có trung bình hơn 10 năm kinh nghiệm trong lĩnh vực chuyên môn của họ.',
              Icons.people,
            ),
            SizedBox(height: screenHeight * 0.02), // 2% of screen height
            _buildFeatureCard(
              context,
              'Giải Pháp Cá Nhân Hóa',
              'Chiến lược pháp lý được thiết kế riêng để phù hợp với nhu cầu cụ thể của bạn.',
              Icons.person_pin,
            ),
            SizedBox(height: screenHeight * 0.02), // 2% of screen height
            _buildFeatureCard(
              context,
              'Tập Trung Vào Khách Hàng',
              'Chúng tôi ưu tiên sự giao tiếp rõ ràng và dịch vụ xuất sắc.',
              Icons.favorite,
            ),
          ],
        ),
        tablet: Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                context,
                'Luật sư giàu kinh nghiệm',
                'Luật sư của chúng tôi có trung bình hơn 10 năm kinh nghiệm trong lĩnh vực chuyên môn của họ.',
                Icons.people,
              ),
            ),
            SizedBox(width: screenWidth * 0.03), // 3% of screen width
            Expanded(
              child: _buildFeatureCard(
                context,
                'Giải Pháp Cá Nhân Hóa',
                'Chiến lược pháp lý được thiết kế riêng để phù hợp với nhu cầu cụ thể của bạn.',
                Icons.person_pin,
              ),
            ),
            SizedBox(width: screenWidth * 0.03), // 3% of screen width
            Expanded(
              child: _buildFeatureCard(
                context,
                'Tập Trung Vào Khách Hàng',
                'Chúng tôi ưu tiên sự giao tiếp rõ ràng và dịch vụ xuất sắc.',
                Icons.favorite,
              ),
            ),
          ],
        ),
        desktop: Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                context,
                'Luật sư giàu kinh nghiệm',
                'Luật sư của chúng tôi có trung bình hơn 10 năm kinh nghiệm trong lĩnh vực chuyên môn của họ.',
                Icons.people,
              ),
            ),
            SizedBox(width: screenWidth * 0.04), // 4% of screen width
            Expanded(
              child: _buildFeatureCard(
                context,
                'Giải Pháp Cá Nhân Hóa',
                'Chiến lược pháp lý được thiết kế riêng để phù hợp với nhu cầu cụ thể của bạn.',
                Icons.person_pin,
              ),
            ),
            SizedBox(width: screenWidth * 0.04), // 4% of screen width
            Expanded(
              child: _buildFeatureCard(
                context,
                'Tập Trung Vào Khách Hàng',
                'Chúng tôi ưu tiên sự giao tiếp rõ ràng và dịch vụ xuất sắc.',
                Icons.favorite,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, String description, IconData icon) {
    final screenWidth = ResponsiveHelper.getScreenWidth(context);
    final screenHeight = ResponsiveHelper.getScreenHeight(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context, 
        mobile: screenWidth * 0.05, 
        tablet: screenWidth * 0.04, 
        desktop: screenWidth * 0.06
      )),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isTablet
          ? Column(
              children: [
                Container(
                  width: screenWidth * 0.15, // 15% of screen width
                  height: screenWidth * 0.15,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF1E3A8A),
                    size: screenWidth * 0.07, // 7% of screen width
                  ),
                ),
                SizedBox(height: screenHeight * 0.02), // 2% of screen height
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04, // 4% of screen width
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A8A),
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.01), // 1% of screen height
                Text(
                  description,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035, // 3.5% of screen width
                    color: Colors.grey[600],
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  width: screenWidth * 0.12, // 12% of screen width
                  height: screenWidth * 0.12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF1E3A8A),
                    size: screenWidth * 0.06, // 6% of screen width
                  ),
                ),
                SizedBox(width: screenWidth * 0.04), // 4% of screen width
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035, // 3.5% of screen width
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E3A8A),
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01), // 1% of screen height
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: screenWidth * 0.03, // 3% of screen width
                          color: Colors.grey[600],
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
