import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../admin/data/services/user_storage_service.dart';
import '../../../admin/data/models/admin_user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await UserStorageService.loginUser(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (user != null) {
        await UserStorageService.setCurrentUser(user);
        if (mounted) {
          _showSuccessSnackBar('Đăng nhập thành công!');
          _navigateToDashboard(user.role);
        }
      } else {
        _showErrorSnackBar('Email hoặc mật khẩu không đúng');
      }
    } catch (e) {
      _showErrorSnackBar('Có lỗi xảy ra: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToDashboard(UserRole role) {
    switch (role) {
      case UserRole.admin:
        context.go('/admin/dashboard');
        break;
      case UserRole.lawyer:
        context.go('/lawyer/dashboard');
        break;
      case UserRole.customer:
        context.go('/home');
        break;
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  SizedBox(height: 40.h),

                  // Logo and Brand
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.gavel,
                      size: 60.w,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  Text(
                    'BASICO LAW',
                    style: TextStyle(
                      fontSize: screenWidth * 0.08,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Hệ thống đặt lịch luật sư',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40.h),

                  // Login Form Card
                  Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Đăng nhập',
                            style: TextStyle(
                              fontSize: screenWidth * 0.06,
                              color: const Color(0xFF1E3A8A),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Chào mừng bạn quay trở lại',
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 32.h),

                          // Email field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(fontSize: screenWidth * 0.04),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: Colors.grey[600],
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: const Color(0xFF1E3A8A),
                                size: 20.w,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 16.h,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập email';
                              }
                              if (!value.contains('@')) {
                                return 'Email không hợp lệ';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16.h),

                          // Password field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: TextStyle(fontSize: screenWidth * 0.04),
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu',
                              labelStyle: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: Colors.grey[600],
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: const Color(0xFF1E3A8A),
                                size: 20.w,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey[600],
                                  size: 20.w,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 16.h,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập mật khẩu';
                              }
                              if (value.length < 6) {
                                return 'Mật khẩu phải có ít nhất 6 ký tự';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 8.h),

                          // Forgot password link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                context.go('/forgot-password');
                              },
                              child: Text(
                                'Quên mật khẩu?',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: const Color(0xFF1E3A8A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Login button
                          Container(
                            height: 50.h,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF1E3A8A).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.w,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Đăng nhập',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.045,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.grey[300],
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: Text(
                                  'hoặc',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey[300],
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24.h),

                          // Register link
                          Container(
                            height: 50.h,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFF1E3A8A), width: 2),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: OutlinedButton(
                              onPressed: () {
                                context.go('/register');
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                'Tạo tài khoản mới',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  color: const Color(0xFF1E3A8A),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // Demo link
                          TextButton(
                            onPressed: () {
                              context.go('/home');
                            },
                            child: Text(
                              'Quay lại trang chủ',
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: Colors.grey[600],
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),

                  // Footer
                  Text(
                    '© 2024 Basico Law Firm. Tất cả quyền được bảo lưu.',
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
