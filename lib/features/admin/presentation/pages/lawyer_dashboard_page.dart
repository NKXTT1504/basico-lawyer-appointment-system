import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/user_storage_service.dart';
import '../../data/models/admin_user.dart';
import '../../data/models/appointment.dart';
import '../../data/models/lawyer.dart';

class LawyerDashboardPage extends StatefulWidget {
  const LawyerDashboardPage({super.key});

  @override
  State<LawyerDashboardPage> createState() => _LawyerDashboardPageState();
}

class _LawyerDashboardPageState extends State<LawyerDashboardPage> {
  User? _currentUser;
  int _totalAppointments = 0;
  int _pendingAppointments = 0;
  int _confirmedAppointments = 0;
  int _completedAppointments = 0;
  int _cancelledAppointments = 0;
  double _totalRevenue = 0;
  double _monthlyRevenue = 0;
  List<Appointment> _recentAppointments = [];
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
        final lawyers = await UserStorageService.getLawyers();
        final me = lawyers.firstWhere(
            (l) => l.email.toLowerCase() == user.email.toLowerCase(),
            orElse: () => throw 'Không tìm thấy hồ sơ luật sư');
        final appointments =
            await UserStorageService.getLawyerAppointments(me.id);

        // Calculate statistics
        final now = DateTime.now();
        final thisMonth = DateTime(now.year, now.month);
        final nextMonth = DateTime(now.year, now.month + 1);

        final completedAppointments = appointments
            .where((apt) => apt.status == AppointmentStatus.completed)
            .toList();

        final monthlyAppointments = completedAppointments
            .where((apt) =>
                apt.appointmentDate.isAfter(thisMonth) &&
                apt.appointmentDate.isBefore(nextMonth))
            .toList();

        final totalRevenue =
            completedAppointments.fold(0.0, (sum, apt) => sum + apt.fee);

        final monthlyRevenue =
            monthlyAppointments.fold(0.0, (sum, apt) => sum + apt.fee);

        // Get recent data
        final recentAppointments = appointments
            .where((apt) =>
                apt.createdAt.isAfter(now.subtract(const Duration(days: 7))))
            .take(5)
            .toList();

        if (mounted) {
          setState(() {
            _currentUser = user;
            _totalAppointments = appointments.length;
            _pendingAppointments = appointments
                .where((apt) => apt.status == AppointmentStatus.pending)
                .length;
            _confirmedAppointments = appointments
                .where((apt) => apt.status == AppointmentStatus.confirmed)
                .length;
            _completedAppointments = appointments
                .where((apt) => apt.status == AppointmentStatus.completed)
                .length;
            _cancelledAppointments = appointments
                .where((apt) => apt.status == AppointmentStatus.cancelled)
                .length;
            _totalRevenue = totalRevenue;
            _monthlyRevenue = monthlyRevenue;
            _recentAppointments = recentAppointments;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          context.go('/login');
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
      context.go('/login');
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

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isMobile ? 16 : 20),
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 20 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Quản lý hệ thống đặt lịch luật sư',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: isMobile ? 14 : 16,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: isMobile ? 20 : 24),
// Statistics cards (simplified for lawyer)
            Text(
              'Thống kê tổng quan',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                    fontSize: isMobile ? 18 : 20,
                  ),
            ),
            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                final int crossAxisCount = 2;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: isMobile ? 12 : 16,
                  mainAxisSpacing: isMobile ? 12 : 16,
                  childAspectRatio: isMobile ? 1.3 : 1.5,
                  children: [
                    _buildStatCard(
                      'Đặt lịch',
                      _totalAppointments.toString(),
                      Icons.calendar_today,
                      Colors.purple,
                    ),
                    _buildStatCard(
                      'Doanh thu tháng',
                      '₫${_monthlyRevenue.toStringAsFixed(0)}',
                      Icons.attach_money,
                      Colors.blue,
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: isMobile ? 20 : 24),

            // Appointment status
            Text(
              'Trạng thái đặt lịch',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                    fontSize: isMobile ? 18 : 20,
                  ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (isMobile) {
                  return Column(
                    children: [
                      _buildStatusCard(
                        'Chờ xác nhận',
                        _pendingAppointments.toString(),
                        Colors.amber,
                        Icons.schedule,
                      ),
                      const SizedBox(height: 12),
                      _buildStatusCard(
                        'Đã xác nhận',
                        _confirmedAppointments.toString(),
                        Colors.blue,
                        Icons.check_circle,
                      ),
                      const SizedBox(height: 12),
                      _buildStatusCard(
                        'Hoàn thành',
                        _completedAppointments.toString(),
                        Colors.green,
                        Icons.done_all,
                      ),
                      const SizedBox(height: 12),
                      _buildStatusCard(
                        'Hủy bỏ',
                        (_totalAppointments -
                                _pendingAppointments -
                                _confirmedAppointments -
                                _completedAppointments)
                            .toString(),
                        Colors.red,
                        Icons.cancel,
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
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
                    ],
                  );
                }
              },
            ),

            SizedBox(height: isMobile ? 20 : 24),

            // Revenue overview
            _buildRevenueSection(isMobile),

            SizedBox(height: isMobile ? 20 : 24),

            // Recent appointments
            _buildRecentAppointments(isMobile),

            SizedBox(height: isMobile ? 20 : 24),

            // Quick actions removed for lawyer role
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
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
            size: isMobile ? 28 : 32,
            color: color,
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
      String title, String value, Color color, IconData icon) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
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
            size: isMobile ? 20 : 24,
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
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
              size: isMobile ? 20 : 24,
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: isMobile ? 14 : 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tổng quan doanh thu',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
                fontSize: isMobile ? 18 : 20,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildRevenueCard(
                'Tổng doanh thu',
                '₫${_totalRevenue.toStringAsFixed(0)}',
                Icons.trending_up,
                Colors.green,
                isMobile,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildRevenueCard(
                'Doanh thu tháng này',
                '₫${_monthlyRevenue.toStringAsFixed(0)}',
                Icons.calendar_month,
                Colors.blue,
                isMobile,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRevenueCard(
      String title, String value, IconData icon, Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: isMobile ? 20 : 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAppointments(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today,
                  color: Colors.blue, size: isMobile ? 16 : 20),
              const SizedBox(width: 8),
              Text(
                'Đặt lịch gần đây',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_recentAppointments.isEmpty)
            Center(
              child: Text(
                'Không có đặt lịch nào',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isMobile ? 12 : 14,
                ),
              ),
            )
          else
            ...(_recentAppointments
                .map((apt) => _buildAppointmentItem(apt, isMobile))),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(Appointment appointment, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(appointment.status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.customerName,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${appointment.appointmentDate.day}/${appointment.appointmentDate.month} - ${appointment.timeSlot}',
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 11,
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
}
