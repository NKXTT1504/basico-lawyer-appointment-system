import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AppointmentTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const AppointmentTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTab(
            context,
            text: 'Cuộc hẹn sắp tới',
            index: 0,
            isSelected: selectedIndex == 0,
          ),
          SizedBox(width: screenWidth * 0.04), // 4% of screen width
          _buildTab(
            context,
            text: 'Lịch sử cuộc hẹn',
            index: 1,
            isSelected: selectedIndex == 1,
          ),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, {
    required String text,
    required int index,
    required bool isSelected,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    
    return GestureDetector(
      onTap: () => onTabChanged(index),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * (isTablet ? 0.08 : 0.05), // 8% for tablet, 5% for mobile
          vertical: screenHeight * 0.015, // 1.5% of screen height
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey.shade300,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: screenWidth * (isTablet ? 0.04 : 0.035), // 4% for tablet, 3.5% for mobile
            color: isSelected ? Colors.white : AppColors.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
