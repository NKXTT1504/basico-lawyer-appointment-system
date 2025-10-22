import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/profile_form.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/entities/user_profile.dart';
import '../../data/mock_data/profile_mock_data.dart';

class ProfileDemoPage extends StatelessWidget {
  const ProfileDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Demo Profile Page'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/home'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Role Selection Buttons
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chọn loại tài khoản để xem demo:',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _switchUser(
                          context,
                          UserRole.customer,
                          ProfileMockData.mockCustomerProfile,
                        ),
                        icon: const Icon(Icons.person),
                        label: const Text('Khách hàng'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.all(isTablet ? 12 : 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _switchUser(
                          context,
                          UserRole.lawyer,
                          ProfileMockData.mockLawyerProfile,
                        ),
                        icon: const Icon(Icons.balance),
                        label: const Text('Luật sư'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.all(isTablet ? 12 : 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _switchUser(
                          context,
                          UserRole.admin,
                          ProfileMockData.mockAdminProfile,
                        ),
                        icon: const Icon(Icons.admin_panel_settings),
                        label: const Text('Admin'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.all(isTablet ? 12 : 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ),
          
          // Profile Content
          Expanded(
            child: BlocProvider<ProfileBloc>(
              create: (context) => ProfileBloc()..add(const GetProfileRequested()),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isTablet ? 40 : 20),
                child: Center(
                  child: ProfileForm(profile: ProfileMockData.mockCustomerProfile),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _switchUser(
    BuildContext context,
    UserRole role,
    UserProfile profileData,
  ) {
    if (context.mounted) {
      // Show a simple dialog to explain the demo
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Chế độ Demo - ${role.displayName}'),
          content: Text('Bạn đã chuyển sang profile của ${role.displayName}.\nEmail: ${profileData.email}\nTên: ${profileData.fullName}\nSố điện thoại: ${profileData.phoneNumber}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
