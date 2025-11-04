import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/user_storage_service.dart';
import '../../data/models/admin_user.dart';
import '../../data/models/lawyer.dart';
import '../../data/models/appointment.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/page_header.dart';

class LawyerProfilePage extends StatefulWidget {
  const LawyerProfilePage({super.key});

  @override
  State<LawyerProfilePage> createState() => _LawyerProfilePageState();
}

class _LawyerProfilePageState extends State<LawyerProfilePage> {
  User? _currentUser;
  bool _isLoading = true;
  Lawyer? _lawyerProfile;
  int _totalAppointmentsCount = 0;
  int _completedAppointmentsCount = 0;
  int _pendingAppointmentsCount = 0;
  double? _averageRating; // reserved for future backend value

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await UserStorageService.getCurrentUser();
      if (user != null && user.role == UserRole.lawyer) {
        // Load associated lawyer profile by email
        final lawyers = await UserStorageService.getLawyers();
        Lawyer? lawyer;
        try {
          lawyer = lawyers.firstWhere(
              (l) => l.email.toLowerCase() == user.email.toLowerCase());
        } catch (_) {}
        // Compute simple stats from local storage if available
        int total = 0;
        int completed = 0;
        int pending = 0;
        if (lawyer != null) {
          try {
            final appointments =
                await UserStorageService.getLawyerAppointments(lawyer.id);
            total = appointments.length;
            completed = appointments
                .where((a) => a.status == AppointmentStatus.completed)
                .length;
            pending = appointments
                .where((a) => a.status == AppointmentStatus.pending)
                .length;
          } catch (_) {}
        }
        setState(() {
          _currentUser = user;
          _lawyerProfile = lawyer;
          _totalAppointmentsCount = total;
          _completedAppointmentsCount = completed;
          _pendingAppointmentsCount = pending;
          _isLoading = false;
        });
      } else {
        if (mounted) {
          context.go('/login');
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showEditDialog() {
    final nameController =
        TextEditingController(text: _currentUser?.name ?? '');
    final emailController =
        TextEditingController(text: _currentUser?.email ?? '');
    final phoneController =
        TextEditingController(text: _lawyerProfile?.phone ?? '');
    final addressController =
        TextEditingController(text: _lawyerProfile?.address ?? '');
    final specializationController =
        TextEditingController(text: _lawyerProfile?.specialization ?? '');
    final bioController =
        TextEditingController(text: _lawyerProfile?.bio ?? '');
    final originalEmail = _currentUser?.email ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa thông tin'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: specializationController,
                decoration: const InputDecoration(
                  labelText: 'Chuyên môn',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(
                  labelText: 'Tiểu sử',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Find lawyer profile by original email
                final lawyers = await UserStorageService.getLawyers();
                Lawyer? lawyer;
                try {
                  lawyer = lawyers.firstWhere((l) =>
                      l.email.toLowerCase() == originalEmail.toLowerCase());
                } catch (_) {}

                if (lawyer != null) {
                  final updated = lawyer.copyWith(
                    name: nameController.text.trim().isEmpty
                        ? lawyer.name
                        : nameController.text.trim(),
                    email: emailController.text.trim().isEmpty
                        ? lawyer.email
                        : emailController.text.trim().toLowerCase(),
                    phone: phoneController.text.trim().isEmpty
                        ? lawyer.phone
                        : phoneController.text.trim(),
                    address: addressController.text.trim().isEmpty
                        ? lawyer.address
                        : addressController.text.trim(),
                    specialization: specializationController.text.trim().isEmpty
                        ? lawyer.specialization
                        : specializationController.text.trim(),
                    bio: bioController.text.trim().isEmpty
                        ? lawyer.bio
                        : bioController.text.trim(),
                    updatedAt: DateTime.now(),
                  );
                  await UserStorageService.updateLawyer(updated);
                  await UserStorageService.syncLawyerUserAccount(
                    oldEmail: originalEmail,
                    name: updated.name,
                    newEmail: updated.email,
                  );
                  // Refresh current user if email/name changed
                  final refreshed =
                      await UserStorageService.getUserByEmail(updated.email);
                  if (refreshed != null) {
                    await UserStorageService.setCurrentUser(refreshed);
                    setState(() {
                      _currentUser = refreshed;
                      _lawyerProfile = updated;
                    });
                  }
                } else {
                  // If no lawyer profile found, update only user record
                  final users = await UserStorageService.getUsers();
                  final idx = users.indexWhere((u) =>
                      u.email.toLowerCase() == originalEmail.toLowerCase());
                  if (idx != -1) {
                    final updatedUser = users[idx].copyWith(
                      name: nameController.text.trim().isEmpty
                          ? users[idx].name
                          : nameController.text.trim(),
                      email: emailController.text.trim().isEmpty
                          ? users[idx].email
                          : emailController.text.trim().toLowerCase(),
                    );
                    users[idx] = updatedUser;
                    await UserStorageService.saveUsers(users);
                    await UserStorageService.setCurrentUser(updatedUser);
                    setState(() => _currentUser = updatedUser);
                  }
                }

                if (mounted) Navigator.pop(context);
                _showSuccessSnackBar('Cập nhật thông tin thành công');
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Lỗi khi cập nhật: $e'),
                      backgroundColor: AppColors.error),
                );
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu hiện tại',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu mới',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              try {
                final user = await UserStorageService.getCurrentUser();
                if (user == null) return;
                if (user.password != oldController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Mật khẩu hiện tại không đúng'),
                        backgroundColor: AppColors.error),
                  );
                  return;
                }
                if (newController.text.trim().length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Mật khẩu mới phải ≥ 6 ký tự'),
                        backgroundColor: AppColors.error),
                  );
                  return;
                }
                await UserStorageService.updateUserPasswordByEmail(
                    user.email, newController.text.trim());
                final refreshed =
                    await UserStorageService.getUserByEmail(user.email);
                if (refreshed != null) {
                  await UserStorageService.setCurrentUser(refreshed);
                  setState(() => _currentUser = refreshed);
                }
                if (mounted) Navigator.pop(context);
                _showSuccessSnackBar('Đổi mật khẩu thành công');
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Đổi mật khẩu thất bại: $e'),
                      backgroundColor: AppColors.error),
                );
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Thông tin cá nhân',
              subtitle: _currentUser?.email ?? '',
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primary),
                  tooltip: 'Chỉnh sửa',
                  onPressed: _showEditDialog,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Profile Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isMobile ? 20 : 24),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: isMobile ? 40 : 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.gavel,
                      size: isMobile ? 40 : 50,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: isMobile ? 12 : 16),
                  Text(
                    _currentUser?.name ?? 'Luật sư',
                    style: TextStyle(
                      color: AppColors.onPrimary,
                      fontSize: isMobile ? 20 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentUser?.email ?? '',
                    style: TextStyle(
                      color: AppColors.onPrimary.withOpacity(0.9),
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                  SizedBox(height: isMobile ? 8 : 12),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 16,
                        vertical: isMobile ? 6 : 8),
                    decoration: BoxDecoration(
                      color: AppColors.onPrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Luật sư',
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: isMobile ? 20 : 24),

            // Personal Information (render only non-empty fields)
            Builder(builder: (context) {
              final List<Widget> infoRows = [];
              final String name = (_currentUser?.name ?? '').trim();
              final String email = (_currentUser?.email ?? '').trim();
              final String phone = (_lawyerProfile?.phone ?? '').trim();
              final String address = (_lawyerProfile?.address ?? '').trim();
              final String specialization =
                  (_lawyerProfile?.specialization ?? '').trim();
              final String bio = (_lawyerProfile?.bio ?? '').trim();

              if (name.isNotEmpty) {
                infoRows.add(_buildInfoRow(Icons.person, 'Họ và tên', name));
              }
              if (email.isNotEmpty) {
                infoRows.add(_buildInfoRow(Icons.email, 'Email', email));
              }
              if (phone.isNotEmpty) {
                infoRows
                    .add(_buildInfoRow(Icons.phone, 'Số điện thoại', phone));
              }
              if (address.isNotEmpty) {
                infoRows
                    .add(_buildInfoRow(Icons.location_on, 'Địa chỉ', address));
              }
              if (specialization.isNotEmpty) {
                infoRows.add(
                    _buildInfoRow(Icons.work, 'Chuyên môn', specialization));
              }
              if (bio.isNotEmpty) {
                infoRows.add(_buildInfoRow(Icons.info, 'Tiểu sử', bio));
              }

              if (infoRows.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông tin cá nhân',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: isMobile ? 18 : 20,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      child: Column(children: infoRows),
                    ),
                  ),
                ],
              );
            }),

            SizedBox(height: isMobile ? 20 : 24),

            // Professional Statistics (show only when there is real data)
            Builder(builder: (context) {
              final bool showStats = _totalAppointmentsCount > 0 ||
                  _completedAppointmentsCount > 0 ||
                  _pendingAppointmentsCount > 0 ||
                  ((_averageRating ?? 0) > 0);
              if (!showStats) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thống kê nghề nghiệp',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: isMobile ? 18 : 20,
                        ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (isMobile) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    'Tổng lịch hẹn',
                                    _totalAppointmentsCount.toString(),
                                    Icons.calendar_today,
                                    AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    'Đã hoàn thành',
                                    _completedAppointmentsCount.toString(),
                                    Icons.check_circle,
                                    AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    'Đang chờ',
                                    _pendingAppointmentsCount.toString(),
                                    Icons.schedule,
                                    Colors.amber,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if ((_averageRating ?? 0) > 0)
                                  Expanded(
                                    child: _buildStatCard(
                                      'Đánh giá TB',
                                      (_averageRating ?? 0).toStringAsFixed(1),
                                      Icons.star,
                                      Colors.orange,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    'Tổng lịch hẹn',
                                    _totalAppointmentsCount.toString(),
                                    Icons.calendar_today,
                                    AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildStatCard(
                                    'Đã hoàn thành',
                                    _completedAppointmentsCount.toString(),
                                    Icons.check_circle,
                                    AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    'Đang chờ',
                                    _pendingAppointmentsCount.toString(),
                                    Icons.schedule,
                                    Colors.amber,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                if ((_averageRating ?? 0) > 0)
                                  Expanded(
                                    child: _buildStatCard(
                                      'Đánh giá TB',
                                      (_averageRating ?? 0).toStringAsFixed(1),
                                      Icons.star,
                                      Colors.orange,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              );
            }),

            SizedBox(height: isMobile ? 20 : 24),

            // Action Buttons
            if (isMobile) ...[
              // Mobile layout - stacked buttons
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showChangePasswordDialog,
                  icon: const Icon(Icons.lock),
                  label: const Text('Đổi mật khẩu'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ] else ...[
              // Desktop layout - inline buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showEditDialog,
                      icon: const Icon(Icons.edit),
                      label: const Text('Chỉnh sửa (trên thanh tiêu đề)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showChangePasswordDialog,
                      icon: const Icon(Icons.lock),
                      label: const Text('Đổi mật khẩu'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: isMobile ? 18 : 20, color: AppColors.primary),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: isMobile ? 20 : 24, color: color),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
