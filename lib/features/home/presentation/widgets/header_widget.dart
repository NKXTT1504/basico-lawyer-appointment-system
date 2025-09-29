import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/responsive_helper.dart';

class HeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = ResponsiveHelper.getScreenWidth(context);
    final screenHeight = ResponsiveHelper.getScreenHeight(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      title: Row(
        children: [
          Container(
            width: ResponsiveHelper.getResponsiveWidth(context, 
              mobile: screenWidth * 0.08, 
              tablet: screenWidth * 0.06, 
              desktop: screenWidth * 0.05
            ),
            height: ResponsiveHelper.getResponsiveWidth(context, 
              mobile: screenWidth * 0.08, 
              tablet: screenWidth * 0.06, 
              desktop: screenWidth * 0.05
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.balance,
              color: Colors.white,
              size: ResponsiveHelper.getResponsiveWidth(context, 
                mobile: screenWidth * 0.05, 
                tablet: screenWidth * 0.04, 
                desktop: screenWidth * 0.035
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.02), // 2% of screen width
          Text(
            'BASICO',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 
                mobile: screenWidth * 0.045, 
                tablet: screenWidth * 0.04, 
                desktop: screenWidth * 0.035
              ),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
            ),
          ),
        ],
      ),
      actions: [
        // Login Button
        TextButton(
          onPressed: () {
            context.go('/login');
          },
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF1E3A8A),
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getResponsivePadding(context, 
                mobile: screenWidth * 0.03, 
                tablet: screenWidth * 0.025, 
                desktop: screenWidth * 0.02
              ),
              vertical: ResponsiveHelper.getResponsivePadding(context, 
                mobile: screenHeight * 0.01, 
                tablet: screenHeight * 0.008, 
                desktop: screenHeight * 0.006
              ),
            ),
          ),
          child: Text(
            'Đăng nhập',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 
                mobile: screenWidth * 0.03, 
                tablet: screenWidth * 0.025, 
                desktop: screenWidth * 0.02
              ),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.01), // 1% of screen width
        // Register Button
        ElevatedButton(
          onPressed: () {
            context.go('/register');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getResponsivePadding(context, 
                mobile: screenWidth * 0.04, 
                tablet: screenWidth * 0.03, 
                desktop: screenWidth * 0.025
              ),
              vertical: ResponsiveHelper.getResponsivePadding(context, 
                mobile: screenHeight * 0.01, 
                tablet: screenHeight * 0.008, 
                desktop: screenHeight * 0.006
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            elevation: 0,
            minimumSize: ResponsiveHelper.getButtonSize(context, 
              mobile: Size(0, screenHeight * 0.04), 
              tablet: Size(0, screenHeight * 0.035), 
              desktop: Size(0, screenHeight * 0.03)
            ),
          ),
          child: Text(
            'Đăng ký',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 
                mobile: screenWidth * 0.03, 
                tablet: screenWidth * 0.025, 
                desktop: screenWidth * 0.02
              ),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.04), // 4% of screen width
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
