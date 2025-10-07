import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/responsive_helper.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/profile_bloc.dart';
import '../../../admin/data/models/customer.dart' as admin_customer;
import '../../../admin/data/services/user_storage_service.dart' as storage;
import '../widgets/profile_form.dart';

class ProfilePage extends StatefulWidget {
  final bool readOnly;
  const ProfilePage({super.key, this.readOnly = false});

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
              if (widget.readOnly) {
                return _ProfileView(profile: state.profile);
              }
              return SingleChildScrollView(
                padding: EdgeInsets.all(isTablet ? 40 : 20),
                child: Center(
                  child: ProfileForm(profile: state.profile),
                ),
              );
            }

            if (state is ProfileUpdateSuccess) {
              if (widget.readOnly) {
                return _ProfileView(profile: state.profile);
              }
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
                      context
                          .read<ProfileBloc>()
                          .add(const GetProfileRequested());
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

class _ProfileView extends StatelessWidget {
  final UserProfile profile;
  const _ProfileView({required this.profile});

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    return FutureBuilder<admin_customer.Customer?>(
      future: storage.UserStorageService.getCurrentCustomerProfile(),
      builder: (context, snap) {
        final customer = snap.data;
        return Scaffold(
          backgroundColor: const Color(0xFFF6F7FB),
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0.5,
            title: const Text('Thông tin cá nhân',
                style: TextStyle(color: Colors.black)),
            actions: [
              IconButton(
                tooltip: 'Chỉnh sửa',
                onPressed: () => context.go('/profile/edit'),
                icon: const Icon(Icons.edit),
                color: const Color(0xFF1E3A8A),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: isTablet ? 30 : 26,
                        backgroundColor:
                            const Color(0xFF1E3A8A).withOpacity(0.1),
                        child:
                            const Icon(Icons.person, color: Color(0xFF1E3A8A)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profile.fullName,
                                style: TextStyle(
                                    fontSize: isTablet ? 18 : 16,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E3A8A))),
                            const SizedBox(height: 4),
                            Text(profile.email,
                                style: TextStyle(color: Colors.grey[700])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(isTablet ? 20 : 16),
                  child: Column(
                    children: [
                      _tile(
                          icon: Icons.phone,
                          label: 'Số điện thoại',
                          value: profile.phoneNumber.isNotEmpty
                              ? profile.phoneNumber
                              : 'Chưa cập nhật'),
                      _divider(),
                      _tile(
                          icon: Icons.location_on,
                          label: 'Địa chỉ',
                          value: customer?.address ?? 'Chưa cập nhật'),
                      _divider(),
                      _tile(
                          icon: Icons.transgender,
                          label: 'Giới tính',
                          value: customer?.gender ?? 'Chưa cập nhật'),
                      _divider(),
                      _tile(
                          icon: Icons.cake,
                          label: 'Ngày sinh',
                          value: customer == null
                              ? 'Chưa cập nhật'
                              : '${customer.dateOfBirth.day}/${customer.dateOfBirth.month}/${customer.dateOfBirth.year}'),
                      _divider(),
                      _tile(
                          icon: Icons.work,
                          label: 'Nghề nghiệp',
                          value: customer?.occupation ?? 'Chưa cập nhật'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // legacy helper removed
  Widget _tile(
      {required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.grey[700], fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Divider(color: Colors.grey.shade200, height: 1),
      );
}
