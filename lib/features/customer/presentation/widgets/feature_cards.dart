import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/theme/app_colors.dart';

class FeatureCards extends StatelessWidget {
  const FeatureCards({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = ResponsiveHelper.getScreenWidth(context);
    final screenHeight = ResponsiveHelper.getScreenHeight(context);

    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context,
          mobile: screenWidth * 0.05,
          tablet: screenWidth * 0.06,
          desktop: screenWidth * 0.08)),
      child: ResponsiveHelper.getResponsiveLayout(
        context,
        mobile: Column(
          children: [
            _buildFeatureCard(
              context,
              'Luật sư giàu kinh nghiệm',
              'Luật sư của chúng tôi có trung bình hơn 10 năm kinh nghiệm trong lĩnh vực chuyên môn của họ.',
              Icons.people,
            ),
            SizedBox(height: screenHeight * 0.02),
            _buildFeatureCard(
              context,
              'Giải Pháp Cá Nhân Hóa',
              'Chiến lược pháp lý được thiết kế riêng để phù hợp với nhu cầu cụ thể của bạn.',
              Icons.person_pin,
            ),
            SizedBox(height: screenHeight * 0.02),
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
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: _buildFeatureCard(
                context,
                'Giải Pháp Cá Nhân Hóa',
                'Chiến lược pháp lý được thiết kế riêng để phù hợp với nhu cầu cụ thể của bạn.',
                Icons.person_pin,
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
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
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: _buildFeatureCard(
                context,
                'Giải Pháp Cá Nhân Hóa',
                'Chiến lược pháp lý được thiết kế riêng để phù hợp với nhu cầu cụ thể của bạn.',
                Icons.person_pin,
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
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

  Widget _buildFeatureCard(
      BuildContext context, String title, String description, IconData icon) {
    final screenWidth = ResponsiveHelper.getScreenWidth(context);
    final screenHeight = ResponsiveHelper.getScreenHeight(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getResponsivePadding(context,
          mobile: screenWidth * 0.05,
          tablet: screenWidth * 0.04,
          desktop: screenWidth * 0.06)),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outline,
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
                  width: screenWidth * 0.15,
                  height: screenWidth * 0.15,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: screenWidth * 0.07,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: AppColors.onSurfaceVariant,
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
                  width: screenWidth * 0.12,
                  height: screenWidth * 0.12,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: screenWidth * 0.06,
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          color: AppColors.onSurfaceVariant,
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
