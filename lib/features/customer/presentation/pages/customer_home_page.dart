import 'package:flutter/material.dart';
import '../widgets/hero_section.dart';
import '../widgets/feature_cards.dart';
import '../widgets/testimonials_section.dart';
import '../../../../core/theme/app_colors.dart';

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const HeroSection(),
              const FeatureCards(),
              const TestimonialsSection(),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.03,
                ),
                color: AppColors.primary,
                child: Column(
                  children: [
                    Text(
                      'BASICO LAW FIRM',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onPrimary,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Text(
                      'Giải pháp pháp lý chuyên nghiệp cho mọi nhu cầu',
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        color: AppColors.onPrimary.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      '© 2025 Basico Law Firm. Tất cả quyền được bảo lưu.',
                      style: TextStyle(
                        fontSize: screenWidth * 0.025,
                        color: AppColors.onPrimary.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
