import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/responsive_helper.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = ResponsiveHelper.getScreenWidth(context);
    final screenHeight = ResponsiveHelper.getScreenHeight(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Container(
      height: ResponsiveHelper.getResponsiveHeight(context,
          mobile: screenHeight * 0.5,
          tablet: screenHeight * 0.55,
          desktop: screenHeight * 0.6),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF1E40AF),
            Color(0xFF1E3A8A),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background Image with overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF1E3A8A).withOpacity(0.7),
                      const Color(0xFF1E3A8A).withOpacity(0.9),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Content
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(screenWidth *
                  (isTablet ? 0.08 : 0.05)), // 8% for tablet, 5% for mobile
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Giải pháp chuyên nghiệp',
                    style: TextStyle(
                      fontSize: screenWidth *
                          (isTablet
                              ? 0.08
                              : 0.06), // 8% for tablet, 6% for mobile
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01), // 1% of screen height
                  Text(
                    'Vì sự thành công của bạn',
                    style: TextStyle(
                      fontSize: screenWidth *
                          (isTablet
                              ? 0.06
                              : 0.045), // 6% for tablet, 4.5% for mobile
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(
                      height: screenHeight * 0.025), // 2.5% of screen height
                  Text(
                    'Đội ngũ luật sư giàu kinh nghiệm của chúng tôi cung cấp các dịch vụ pháp lý cá nhân để giúp bạn giải quyết các vấn đề pháp lý phức tạp một cách tự tin và an tâm.',
                    style: TextStyle(
                      fontSize: screenWidth *
                          (isTablet
                              ? 0.04
                              : 0.035), // 4% for tablet, 3.5% for mobile
                      color: Colors.white,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04), // 4% of screen height
                  // Buttons responsive layout
                  isTablet
                      ? Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  context.go('/service-field-selection');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF1E3A8A),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth *
                                        0.06, // 6% of screen width
                                    vertical: screenHeight *
                                        0.02, // 2% of screen height
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Đặt lịch tư vấn',
                                  style: TextStyle(
                                    fontSize: screenWidth *
                                        0.04, // 4% of screen width
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                                width:
                                    screenWidth * 0.04), // 4% of screen width
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  context.go('/service-selection');
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(
                                      color: Colors.white, width: 2),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth *
                                        0.06, // 6% of screen width
                                    vertical: screenHeight *
                                        0.02, // 2% of screen height
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Khám phá dịch vụ',
                                      style: TextStyle(
                                        fontSize: screenWidth *
                                            0.04, // 4% of screen width
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(
                                        width: screenWidth *
                                            0.02), // 2% of screen width
                                    Icon(Icons.arrow_forward,
                                        size: screenWidth *
                                            0.045), // 4.5% of screen width
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                context.go('/service-field-selection');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF1E3A8A),
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      screenWidth * 0.06, // 6% of screen width
                                  vertical: screenHeight *
                                      0.02, // 2% of screen height
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Đặt lịch tư vấn',
                                style: TextStyle(
                                  fontSize: screenWidth *
                                      0.035, // 3.5% of screen width
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                                height: screenHeight *
                                    0.015), // 1.5% of screen height
                            OutlinedButton(
                              onPressed: () {
                                context.go('/service-selection');
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                    color: Colors.white, width: 2),
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      screenWidth * 0.06, // 6% of screen width
                                  vertical: screenHeight *
                                      0.02, // 2% of screen height
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Khám phá dịch vụ',
                                    style: TextStyle(
                                      fontSize: screenWidth *
                                          0.035, // 3.5% of screen width
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                      width: screenWidth *
                                          0.02), // 2% of screen width
                                  Icon(Icons.arrow_forward,
                                      size: screenWidth *
                                          0.04), // 4% of screen width
                                ],
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
    );
  }
}
