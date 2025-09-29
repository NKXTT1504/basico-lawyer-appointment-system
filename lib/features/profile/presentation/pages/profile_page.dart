import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/profile_form.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const GetProfileRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is ProfileUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is ProfileUpdateLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Đang cập nhật thông tin...',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is ProfileLoaded) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(isTablet ? 40 : 20),
                child: Center(
                  child: ProfileForm(profile: state.profile),
                ),
              );
            }

            if (state is ProfileUpdateSuccess) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(isTablet ? 40 : 20),
                child: Center(
                  child: ProfileForm(profile: state.profile),
                ),
              );
            }

            if (state is PasswordChangeLoading) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(isTablet ? 40 : 20),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Đang thay đổi mật khẩu...',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ProfileForm(profile: state.profile),
                    ],
                  ),
                ),
              );
            }

            if (state is PasswordChangeSuccess) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(isTablet ? 40 : 20),
                child: Center(
                  child: ProfileForm(profile: state.profile),
                ),
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: isTablet ? 80 : 60,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không thể tải thông tin',
                    style: TextStyle(
                      fontSize: isTablet ? 20 : 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      context.read<ProfileBloc>().add(const GetProfileRequested());
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
