import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class HeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      title: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(
              Icons.balance,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'BASICO',
            style: TextStyle(
              fontSize: 18.sp,
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
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          ),
          child: Text(
            'Đăng nhập',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        // Register Button
        ElevatedButton(
          onPressed: () {
            context.go('/register');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.r),
            ),
            elevation: 0,
            minimumSize: Size(0, 32.h),
          ),
          child: Text(
            'Đăng ký',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: 16.w),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
