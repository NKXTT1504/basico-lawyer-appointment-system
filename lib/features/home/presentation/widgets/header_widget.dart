import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_helper.dart';

class HeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  const HeaderWidget({super.key});

  // Removed dynamic user actions in header per requirement

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
            padding:
                EdgeInsets.only(left: screenWidth * 0.04), // 4% of screen width
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
                    desktop: screenWidth * 0.035),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E3A8A),
              ),
            ),
          ),
        ],
      ),
      actions: const [SizedBox(width: 12)],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
