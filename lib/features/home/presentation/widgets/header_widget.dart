import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/responsive_helper.dart';

class HeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = ResponsiveHelper.getScreenWidth(context);
    
    return AppBar(
      centerTitle: false,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: screenWidth * 0.04), // 4% of screen width
            child: Icon(
              Icons.gavel,
              size: screenWidth * 0.06, // 6% of screen width
              color: const Color(0xFF1E3A8A),
            ),
          ),
          Expanded(
            child: Text(
            'BASICO',
            style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 
                  mobile: screenWidth * 0.05, 
                  tablet: screenWidth * 0.04,
                  desktop: screenWidth * 0.035
                ),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: () => context.go('/login'),
          icon: const Icon(Icons.login, color: Color(0xFF1E3A8A)),
          label: Text(
            'Đăng nhập',
            style: TextStyle(color: Colors.grey.shade800, fontSize: 16),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () => context.go('/register'),
          icon: const Icon(Icons.person_add, color: Color(0xFF1E3A8A)),
          label: Text(
            'Đăng ký',
            style: TextStyle(color: Colors.grey.shade800, fontSize: 16),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}