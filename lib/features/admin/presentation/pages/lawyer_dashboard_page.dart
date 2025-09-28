import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/user_storage_service.dart';
import '../../data/models/admin_user.dart';
import '../../data/models/appointment.dart';

class LawyerDashboardPage extends StatefulWidget {
  const LawyerDashboardPage({super.key});

  @override
  State<LawyerDashboardPage> createState() => _LawyerDashboardPageState();
}

class _LawyerDashboardPageState extends State<LawyerDashboardPage> {
  User? _currentUser;
  List<Appointment> _myAppointments = [];
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
      if (user != null && user.role == UserRole.lawyer) {
        final appointments =
            await UserStorageService.getLawyerAppointments(user.id);
        if (mounted) {
          setState(() {
            _currentUser = user;
            _myAppointments = appointments;
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _updateAppointmentStatus(
      Appointment appointment, AppointmentStatus newStatus) async {
    try {
      final updatedAppointment = appointment.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      await UserStorageService.updateAppointment(updatedAppointment);
      await _loadData();
      _showSuccessSnackBar('Cập nhật trạng thái thành công');
    } catch (e) {
      _showErrorSnackBar('Có lỗi xảy ra: $e');
    }
  }

  Future<void> _logout() async {
    await UserStorageService.setCurrentUser(null);
    if (mounted) {
      context.go('/role-login');
    }
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Colors.amber;
      case AppointmentStatus.confirmed:
        return Colors.blue;
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Chờ xác nhận';
      case AppointmentStatus.confirmed:
        return 'Đã xác nhận';
      case AppointmentStatus.completed:
        return 'Hoàn thành';
      case AppointmentStatus.cancelled:
        return 'Đã hủy';
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
        title: const Text('Dashboard Luật sư'),
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
                    'Chào mừng, ${_currentUser?.name ?? 'Luật sư'}!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Quản lý lịch hẹn của bạn',
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
              'Thống kê lịch hẹn',
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
                  'Tổng lịch hẹn',
                  _myAppointments.length.toString(),
                  Icons.calendar_today,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Chờ xác nhận',
                  _myAppointments
                      .where((apt) => apt.status == AppointmentStatus.pending)
                      .length
                      .toString(),
                  Icons.schedule,
                  Colors.amber,
                ),
                _buildStatCard(
                  'Đã xác nhận',
                  _myAppointments
                      .where((apt) => apt.status == AppointmentStatus.confirmed)
                      .length
                      .toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatCard(
                  'Hoàn thành',
                  _myAppointments
                      .where((apt) => apt.status == AppointmentStatus.completed)
                      .length
                      .toString(),
                  Icons.done_all,
                  Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Appointments list
            Text(
              'Lịch hẹn của bạn',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
            ),
            const SizedBox(height: 16),

            if (_myAppointments.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có lịch hẹn nào',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _myAppointments.length,
                itemBuilder: (context, index) {
                  final appointment = _myAppointments[index];
                  return _buildAppointmentCard(appointment);
                },
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

  Widget _buildAppointmentCard(Appointment appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.customerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(appointment.status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getStatusText(appointment.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(appointment.status),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Details
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '${appointment.appointmentDate.day}/${appointment.appointmentDate.month}/${appointment.appointmentDate.year}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  appointment.timeSlot,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '${appointment.fee.toStringAsFixed(0)} VNĐ',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            if (appointment.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment.notes,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Actions
            if (appointment.status == AppointmentStatus.pending) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateAppointmentStatus(
                          appointment, AppointmentStatus.confirmed),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Chấp nhận'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateAppointmentStatus(
                          appointment, AppointmentStatus.cancelled),
                      icon: const Icon(Icons.cancel, size: 16),
                      label: const Text('Từ chối'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (appointment.status == AppointmentStatus.confirmed) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateAppointmentStatus(
                          appointment, AppointmentStatus.completed),
                      icon: const Icon(Icons.done, size: 16),
                      label: const Text('Hoàn thành'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
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
}

