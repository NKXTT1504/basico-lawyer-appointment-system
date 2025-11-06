import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/page_header.dart';
import '../../../admin/data/services/user_storage_service.dart';
import '../../data/services/lawyer_api_service.dart';
import '../../../appointment/data/services/appointment_api_service.dart';
import '../../../admin/data/models/admin_user.dart';
import '../../../admin/data/models/appointment.dart';

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
  double _totalRevenue = 0;
  double _monthlyRevenue = 0;
  List<Appointment> _recentAppointments = [];
  bool _isLoading = true;
  // Range/filtering for month selection (like admin)
  List<Appointment> _allAppointments = [];
  late DateTime _monthStart;
  late DateTime _nextMonthStart;
  DateTime? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await UserStorageService.getCurrentUser();
      if (user != null && user.role == UserRole.lawyer) {
        // Fetch lawyer profile by current userId
        final lawyerResp = await LawyerApiService.getLawyerByUserId(user.id);
        final Map<String, dynamic> lawyerData =
            lawyerResp.data is Map<String, dynamic>
                ? Map<String, dynamic>.from(lawyerResp.data)
                : <String, dynamic>{};
        // Some services wrap payload in { result: {...} }
        final Map<String, dynamic> lawyerProfile =
            (lawyerData['result'] is Map<String, dynamic>
                    ? Map<String, dynamic>.from(
                        lawyerData['result'] as Map<String, dynamic>)
                    : lawyerData)
                .cast<String, dynamic>();

        final String lawyerId =
            (lawyerProfile['id'] ?? lawyerProfile['Id'] ?? '').toString();
        if (lawyerId.isEmpty) {
          throw 'Không tìm thấy hồ sơ luật sư';
        }

        // Fetch all appointments with joined info then filter by lawyerId
        final appointmentsResp =
            await AppointmentApiService.getAllAppointments();
        final List<dynamic> appointmentsData =
            (appointmentsResp.data is Map<String, dynamic>
                    ? (appointmentsResp.data['result'] as List? ?? [])
                    : (appointmentsResp.data as List? ?? []))
                .toList();

        final appointments = appointmentsData
            .map((json) => Appointment.fromJson(json as Map<String, dynamic>))
            .where((apt) => apt.lawyerId.toString() == lawyerId)
            .toList();

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
            // keep raw appointments, range is applied via _applyRange
            _allAppointments = appointments;
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
            _totalRevenue = totalRevenue;
            _monthlyRevenue = monthlyRevenue;
            _recentAppointments = recentAppointments;
            _isLoading = false;
          });
          // initialize month anchors and apply month range to top KPIs
          final now = DateTime.now();
          _selectedMonth ??= DateTime(now.year, now.month);
          _monthStart = DateTime(_selectedMonth!.year, _selectedMonth!.month);
          _nextMonthStart =
              DateTime(_selectedMonth!.year, _selectedMonth!.month + 1);
          _applyRange();
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

  void _applyRange() {
    // Apply selected month to Lawyer KPIs: appointments count and monthly revenue
    final now = DateTime.now();
    final bool isCurrentMonth =
        _monthStart.year == now.year && _monthStart.month == now.month;
    final DateTime endBound = isCurrentMonth
        ? DateTime(now.year, now.month, now.day + 1)
        : _nextMonthStart;

    final rangeApts = _allAppointments.where((a) =>
        !a.appointmentDate.isBefore(_monthStart) &&
        a.appointmentDate.isBefore(endBound));

    final int monthlyAppointmentsCount = rangeApts.length;
    final double monthlyRevenue = rangeApts
        .where((a) => a.status == AppointmentStatus.completed)
        .fold<double>(
            0.0, (sum, a) => sum + (a.fee.isFinite && a.fee > 0 ? a.fee : 0));

    setState(() {
      _totalAppointments = monthlyAppointmentsCount;
      _monthlyRevenue = monthlyRevenue;
    });
  }

  // logout unused in lawyer dashboard

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
              title: 'Bảng điều khiển luật sư',
              subtitle:
                  'Chào mừng, ${_currentUser?.name ?? 'Luật sư'} · Quản lý hoạt động và đặt lịch',
            ),

            SizedBox(height: isMobile ? 20 : 24),
// Statistics cards (simplified for lawyer)
            Row(
              children: [
                Text(
                  'Thống kê tổng quan',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: isMobile ? 18 : 20,
                      ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: InkWell(
                    onTap: () async {
                      final today = DateTime.now();
                      final initial =
                          _selectedMonth ?? DateTime(today.year, today.month);
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: initial,
                        firstDate: DateTime(today.year - 3, 1),
                        lastDate: DateTime(today.year + 3, 12),
                      );
                      if (picked != null) {
                        _selectedMonth = DateTime(picked.year, picked.month);
                        _monthStart = DateTime(
                            _selectedMonth!.year, _selectedMonth!.month);
                        _nextMonthStart = DateTime(
                            _selectedMonth!.year, _selectedMonth!.month + 1);
                        _applyRange();
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          _selectedMonth == null
                              ? '--/----'
                              : '${_monthStart.month}/${_monthStart.year}',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
                      AppColors.secondary,
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

  // quick action card removed for lawyer role

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
