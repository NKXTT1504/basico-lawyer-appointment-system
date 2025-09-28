import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/user_storage_service.dart';
import '../../data/models/admin_user.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  User? _currentUser;
  int _totalCustomers = 0;
  int _totalLawyers = 0;
  int _totalAppointments = 0;
  int _pendingAppointments = 0;
  int _confirmedAppointments = 0;
  int _completedAppointments = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Initialize sample data if needed
      await UserStorageService.initializeSampleData();

      final user = await UserStorageService.getCurrentUser();
      if (user != null && user.role == UserRole.admin) {
        final customers = await UserStorageService.getCustomers();
        final lawyers = await UserStorageService.getLawyers();
        final appointments = await UserStorageService.getAppointments();

        if (mounted) {
          setState(() {
            _currentUser = user;
            _totalCustomers = customers.length;
            _totalLawyers = lawyers.length;
            _totalAppointments = appointments.length;
            _pendingAppointments = appointments
                .where((apt) => apt.status.name == 'pending')
                .length;
            _confirmedAppointments = appointments
                .where((apt) => apt.status.name == 'confirmed')
                .length;
            _completedAppointments = appointments
                .where((apt) => apt.status.name == 'completed')
                .length;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          context.go('/role-login');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Có lỗi xảy ra: $e');
      }
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

  Future<void> _logout() async {
    await UserStorageService.setCurrentUser(null);
    if (mounted) {
      context.go('/role-login');
    }
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

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Đăng xuất'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue[600]!,
                    Colors.blue[400]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chào mừng, ${_currentUser?.name ?? 'Admin'}!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Quản lý hệ thống đặt lịch luật sư',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Statistics cards
            Text(
              'Thống kê tổng quan',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  'Khách hàng',
                  _totalCustomers.toString(),
                  Icons.person,
                  Colors.green,
                ),
                _buildStatCard(
                  'Luật sư',
                  _totalLawyers.toString(),
                  Icons.gavel,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Đặt lịch',
                  _totalAppointments.toString(),
                  Icons.calendar_today,
                  Colors.purple,
                ),
                _buildStatCard(
                  'Doanh thu',
                  '₫0',
                  Icons.attach_money,
                  Colors.blue,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Appointment status
            Text(
              'Trạng thái đặt lịch',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    'Chờ xác nhận',
                    _pendingAppointments.toString(),
                    Colors.amber,
                    Icons.schedule,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatusCard(
                    'Đã xác nhận',
                    _confirmedAppointments.toString(),
                    Colors.blue,
                    Icons.check_circle,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    'Hoàn thành',
                    _completedAppointments.toString(),
                    Colors.green,
                    Icons.done_all,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatusCard(
                    'Hủy bỏ',
                    (_totalAppointments -
                            _pendingAppointments -
                            _confirmedAppointments -
                            _completedAppointments)
                        .toString(),
                    Colors.red,
                    Icons.cancel,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Quick actions
            Text(
              'Thao tác nhanh',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
              children: [
                _buildActionCard(
                  'Quản lý đặt lịch',
                  Icons.calendar_today,
                  Colors.blue,
                  () => context.go('/admin/appointments'),
                ),
                _buildActionCard(
                  'Quản lý khách hàng',
                  Icons.person,
                  Colors.orange,
                  () => context.go('/admin/customers'),
                ),
                _buildActionCard(
                  'Quản lý luật sư',
                  Icons.gavel,
                  Colors.purple,
                  () => context.go('/admin/lawyers'),
                ),
                _buildActionCard(
                  'Báo cáo thống kê',
                  Icons.analytics,
                  Colors.green,
                  () => _showErrorSnackBar(
                      'Chức năng báo cáo đang được phát triển'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
