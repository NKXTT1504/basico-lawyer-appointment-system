import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeatureCards extends StatelessWidget {
  const FeatureCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          _buildFeatureCard(
            'Luật sư giàu kinh nghiệm',
            'Luật sư của chúng tôi có trung bình hơn 10 năm kinh nghiệm trong lĩnh vực chuyên môn của họ.',
            Icons.people,
          ),
          SizedBox(height: 16.h),
          _buildFeatureCard(
            'Giải Pháp Cá Nhân Hóa',
            'Chiến lược pháp lý được thiết kế riêng để phù hợp với nhu cầu cụ thể của bạn.',
            Icons.person_pin,
          ),
          SizedBox(height: 16.h),
          _buildFeatureCard(
            'Tập Trung Vào Khách Hàng',
            'Chúng tôi ưu tiên sự giao tiếp rõ ràng và dịch vụ xuất sắc.',
            Icons.favorite,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
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
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1E3A8A),
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A8A),
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.sp,
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
