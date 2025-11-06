import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/page_header.dart';
import '../../data/models/admin_user.dart';
import '../../data/models/appointment.dart';
import '../../../customer/data/models/customer.dart';
import '../../../lawyer/data/models/lawyer.dart';
import '../controllers/admin_dashboard_controller.dart';
// import '../../../../core/services/admin_report_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final AdminDashboardController _controller = AdminDashboardController();
  User? _currentUser;
  int _totalCustomers = 0;
  int _totalLawyers = 0;
  int _totalAppointments = 0;
  int _pendingAppointments = 0;
  int _confirmedAppointments = 0;
  int _completedAppointments = 0;
  // int _cancelledAppointments = 0; // kept for future charts (unused)
  double _totalRevenue = 0; // kept for future charts
  double _monthlyRevenue = 0;
  List<Appointment> _recentAppointments = [];
  List<Customer> _recentCustomers = [];
  // List<Lawyer> _activeLawyers = [];
  bool _isLoading = true;
  // Range/filtering
  List<Appointment> _allAppointments = [];
  bool _monthlyMode = true; // true: current month, false: all-time
  late DateTime _monthStart;
  late DateTime _nextMonthStart;
  DateTime? _selectedMonth; // month anchor for monthlyMode
  // Chart data (last 7 days)
  // 1) Xu hướng Thanh Toán Hằng Ngày (số tiền)
  List<double> _seriesPaymentAmount = [];
  // 2) Xu hướng Lịch Hẹn Hằng Ngày (số lượng)
  List<double> _seriesAppointmentCount = [];
  // 3) Phân Phối Đánh Giá (1..5 sao)
  List<double> _barRatings = [0, 0, 0, 0, 0];
  // 4) Thanh Toán Theo Nhà Cung Cấp
  List<_BarItem> _barProviders = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      print('📡 Fetching dashboard data from API...');

      // Load data using controller
      final data = await _controller.loadDashboardData();

      final user = data['user'] as User;
      final customers = data['customers'] as List<Customer>;
      final lawyers = data['lawyers'] as List<Lawyer>;
      final appointments = data['appointments'] as List<Appointment>;
      final stats = data['stats'] as Map<String, dynamic>;

      print(
          '✅ Successfully loaded: ${customers.length} customers, ${lawyers.length} lawyers, ${appointments.length} appointments');

      // Process DashboardStatisticsDto from controller
      try {
        final payments = stats['payments'] as Map<String, dynamic>? ??
            stats['Payments'] as Map<String, dynamic>? ??
            <String, dynamic>{};
        final appointmentsStat =
            stats['appointments'] as Map<String, dynamic>? ??
                stats['Appointments'] as Map<String, dynamic>? ??
                <String, dynamic>{};
        final reviews = stats['reviews'] as Map<String, dynamic>? ??
            stats['Reviews'] as Map<String, dynamic>? ??
            <String, dynamic>{};

        // 1) Payments.DailyStatistics -> _seriesPaymentAmount
        final dailyPay = payments['dailyStatistics'] as List? ??
            payments['DailyStatistics'] as List? ??
            const [];
        final List<double> paySeries = [];
        for (final d in dailyPay) {
          if (d is Map) {
            final amount = d['amount'] ?? d['Amount'] ?? 0;
            paySeries.add((amount is num) ? amount.toDouble() : 0);
          }
        }
        if (paySeries.isNotEmpty) {
          _seriesPaymentAmount = paySeries;
        }

        // 2) Appointments.DailyStatistics -> _seriesAppointmentCount
        final dailyApt = appointmentsStat['dailyStatistics'] as List? ??
            appointmentsStat['DailyStatistics'] as List? ??
            const [];
        final List<double> aptSeries = [];
        for (final d in dailyApt) {
          if (d is Map) {
            final count = d['count'] ?? d['Count'] ?? 0;
            aptSeries.add((count is num) ? count.toDouble() : 0);
          }
        }
        if (aptSeries.isNotEmpty) {
          _seriesAppointmentCount = aptSeries;
        }

        // 3) Reviews.RatingDistribution -> _barRatings [1..5]
        final ratingDist =
            reviews['ratingDistribution'] ?? reviews['RatingDistribution'];
        if (ratingDist is Map) {
          final tmp = List<double>.filled(5, 0);
          ratingDist.forEach((k, v) {
            final key = int.tryParse(k.toString()) ?? 0;
            if (key >= 1 && key <= 5) {
              tmp[key - 1] = (v is num) ? v.toDouble() : 0;
            }
          });
          _barRatings = tmp;
        }

        // 4) Payments.CountByVendor -> _barProviders
        final countByVendor =
            payments['countByVendor'] ?? payments['CountByVendor'];
        if (countByVendor is Map) {
          _barProviders = [];
          countByVendor.forEach((k, v) {
            _barProviders
                .add(_BarItem(k.toString(), (v is num) ? v.toDouble() : 0));
          });
        }
      } catch (_) {}

      // Calculate statistics (fallback)
      final now = DateTime.now();
      _selectedMonth ??= DateTime(now.year, now.month);
      _monthStart = DateTime(_selectedMonth!.year, _selectedMonth!.month);
      _nextMonthStart =
          DateTime(_selectedMonth!.year, _selectedMonth!.month + 1);

      final completedAppointments = appointments
          .where((apt) => apt.status == AppointmentStatus.completed)
          .toList();

      // Appointments completed within current month (inclusive start, exclusive end)
      final monthlyAppointments = completedAppointments
          .where((apt) =>
              !apt.appointmentDate.isBefore(_monthStart) &&
              apt.appointmentDate.isBefore(_nextMonthStart))
          .toList();

      final totalRevenue = completedAppointments.fold(
        0.0,
        (sum, apt) => sum + (apt.fee.isFinite && apt.fee > 0 ? apt.fee : 0),
      );

      final monthlyRevenue = monthlyAppointments.fold(
        0.0,
        (sum, apt) => sum + (apt.fee.isFinite && apt.fee > 0 ? apt.fee : 0),
      );

      // Get recent data
      final recentAppointments = appointments
          .where((apt) => apt.appointmentDate
              .isAfter(now.subtract(const Duration(days: 7))))
          .toList()
        ..sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
      final recentAppointmentsTop5 = recentAppointments.take(5).toList();

      final recentCustomers = customers
          .where((cust) =>
              cust.createdAt.isAfter(now.subtract(const Duration(days: 30))))
          .take(5)
          .toList();

      // final activeLawyers = lawyers.where((lawyer) => lawyer.isActive).take(5).toList();

      if (mounted) {
        setState(() {
          _currentUser = user;
          _totalCustomers = customers.length;
          _totalLawyers = lawyers.length;
          _allAppointments = appointments;
          // cancelled derived at render time
          _totalRevenue = totalRevenue;
          _monthlyRevenue = monthlyRevenue;
          _recentAppointments = recentAppointmentsTop5;
          _recentCustomers = recentCustomers;
          // _activeLawyers = activeLawyers;
          _isLoading = false;
        });
        _applyRange();
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
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _applyRange() {
    // Toggle between monthly and all-time for top stats: appointments and revenue
    final source = _allAppointments;
    Iterable<Appointment> rangeApts;
    if (_monthlyMode) {
      final now = DateTime.now();
      final bool isCurrentMonth =
          _monthStart.year == now.year && _monthStart.month == now.month;
      final DateTime endBound = isCurrentMonth
          ? DateTime(now.year, now.month, now.day + 1)
          : _nextMonthStart;
      rangeApts = source.where((a) =>
          !a.appointmentDate.isBefore(_monthStart) &&
          a.appointmentDate.isBefore(endBound));
    } else {
      rangeApts = source;
    }

    final totalApts = rangeApts.length;
    final pending =
        rangeApts.where((a) => a.status == AppointmentStatus.pending).length;
    final confirmed =
        rangeApts.where((a) => a.status == AppointmentStatus.confirmed).length;
    final completed =
        rangeApts.where((a) => a.status == AppointmentStatus.completed).length;

    final revenue = rangeApts
        .where((a) => a.status == AppointmentStatus.completed)
        .fold<double>(
            0.0, (sum, a) => sum + (a.fee.isFinite && a.fee > 0 ? a.fee : 0));

    setState(() {
      _totalAppointments = totalApts;
      _pendingAppointments = pending;
      _confirmedAppointments = confirmed;
      _completedAppointments = completed;
      if (_monthlyMode) {
        _monthlyRevenue = revenue;
      } else {
        _totalRevenue = revenue;
      }
    });

    _computeSeries();
  }

  void _computeSeries() {
    // Build 7-day series ending today
    final now = DateTime.now();
    List<double> paymentAmount = List.filled(7, 0);
    List<double> apptCount = List.filled(7, 0);

    bool _sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    for (int i = 0; i < 7; i++) {
      final day = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: 6 - i));
      // appointments
      final dayApts =
          _allAppointments.where((a) => _sameDay(a.appointmentDate, day));
      apptCount[i] = dayApts.length.toDouble();
      paymentAmount[i] = dayApts
          .where((a) => a.status == AppointmentStatus.completed)
          .fold<double>(0, (sum, a) => sum + (a.fee.isFinite ? a.fee : 0));
      // ratings / providers fallback left to zeros
    }

    setState(() {
      _seriesPaymentAmount = paymentAmount;
      _seriesAppointmentCount = apptCount;
    });
  }

  // removed unused logout (handled elsewhere)

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
      backgroundColor: AppColors.surfaceVariant,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Bảng điều khiển Admin',
              subtitle:
                  'Chào mừng, ${_currentUser?.name ?? 'Admin'} · Theo dõi hoạt động hệ thống',
            ),

            SizedBox(height: isMobile ? 20 : 24),

            // Statistics cards (re-computed via report service)
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
                        _monthlyMode = true;
                        _applyRange();
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          '${_monthStart.month}/${_monthStart.year}',
                          style: const TextStyle(
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
                int crossAxisCount;
                if (isTablet) {
                  crossAxisCount = 4;
                } else if (isMobile) {
                  crossAxisCount = 2;
                } else {
                  crossAxisCount = 3;
                }

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: isMobile ? 12 : 16,
                  mainAxisSpacing: isMobile ? 12 : 16,
                  childAspectRatio: isMobile ? 1.3 : 1.5,
                  children: [
                    _buildStatCard(
                      'Khách hàng',
                      _totalCustomers.toString(),
                      Icons.person,
                      AppColors.success,
                    ),
                    _buildStatCard(
                      'Luật sư',
                      _totalLawyers.toString(),
                      Icons.gavel,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Tổng doanh thu',
                      '₫${_totalRevenue.toStringAsFixed(0)}',
                      Icons.trending_up,
                      Colors.purple,
                    ),
                    _buildStatCard(
                      'Doanh thu tháng này',
                      '₫${_monthlyRevenue.toStringAsFixed(0)}',
                      Icons.calendar_month,
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
                        AppColors.primary,
                        Icons.check_circle,
                      ),
                      const SizedBox(height: 12),
                      _buildStatusCard(
                        'Hoàn thành',
                        _completedAppointments.toString(),
                        AppColors.success,
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
                        AppColors.error,
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
                              AppColors.primary,
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
                              AppColors.success,
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
                              AppColors.error,
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

            // Charts grid
            _buildChartsGrid(isMobile),

            SizedBox(height: isMobile ? 20 : 24),

            // Recent activity
            _buildRecentActivitySection(isMobile),

            SizedBox(height: isMobile ? 20 : 24),

            // Quick actions
            Text(
              'Thao tác nhanh',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: isMobile ? 18 : 20,
                  ),
            ),
            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount;
                if (isTablet) {
                  crossAxisCount = 4;
                } else if (isMobile) {
                  crossAxisCount = 1;
                } else {
                  crossAxisCount = 2;
                }

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: isMobile ? 12 : 16,
                  mainAxisSpacing: isMobile ? 12 : 16,
                  childAspectRatio: isMobile ? 4.0 : 2.5,
                  children: [
                    _buildActionCard(
                      'Quản lý đặt lịch',
                      Icons.calendar_today,
                      AppColors.primary,
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
                    // Báo cáo thống kê: ẩn theo yêu cầu
                  ],
                );
              },
            ),
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

  // Charts
  Widget _buildChartsGrid(bool isMobile) {
    return LayoutBuilder(builder: (context, constraints) {
      int cross = isMobile ? 2 : 4;
      final cards = <Widget>[
        _chartCard('Xu hướng thanh toán hằng ngày', _seriesPaymentAmount,
            prefix: '₫'),
        _chartCard('Xu hướng lịch hẹn hằng ngày', _seriesAppointmentCount,
            prefix: ''),
        _barChartCard('Phân phối đánh giá',
            labels: const ['1 sao', '2 sao', '3 sao', '4 sao', '5 sao'],
            values: _barRatings,
            color: Colors.orange),
        _barChartCard('Thanh toán theo nhà cung cấp',
            labels: _barProviders.map((e) => e.label).toList(),
            values: _barProviders.map((e) => e.value).toList(),
            color: Colors.purple),
      ];
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: cross,
        crossAxisSpacing: isMobile ? 12 : 16,
        mainAxisSpacing: isMobile ? 12 : 16,
        childAspectRatio: isMobile ? 1.4 : 1.8,
        children: cards,
      );
    });
  }

  Widget _chartCard(String title, List<double> series,
      {String prefix = '', Color? color}) {
    final theme = Theme.of(context);
    final last = series.isNotEmpty ? series.last : 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$prefix${last.toStringAsFixed(0)}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: MiniLineChart(
              data: series,
              strokeColor: (color ?? AppColors.primary),
              fillColor:
                  (color ?? AppColors.primaryContainer).withOpacity(0.25),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barChartCard(String title,
      {required List<String> labels,
      required List<double> values,
      required Color color}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: MiniBarChart(
              labels: labels,
              values: values,
              barColor: color,
            ),
          ),
        ],
      ),
    );
  }

  // sparkline classes moved to bottom-level

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

  // (legacy) revenue section retained for future; not used in mobile layout

  // _buildRevenueCard kept for reference (no longer used)

  Widget _buildRecentActivitySection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hoạt động gần đây',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: isMobile ? 18 : 20,
              ),
        ),
        const SizedBox(height: 16),
        if (isMobile) ...[
          _buildRecentAppointments(isMobile),
          const SizedBox(height: 16),
          _buildRecentCustomers(isMobile),
        ] else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildRecentAppointments(isMobile)),
              const SizedBox(width: 16),
              Expanded(child: _buildRecentCustomers(isMobile)),
            ],
          ),
        ],
      ],
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
                  color: AppColors.primary, size: isMobile ? 16 : 20),
              const SizedBox(width: 8),
              Text(
                'Đặt lịch gần đây',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
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

  Widget _buildRecentCustomers(bool isMobile) {
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
              Icon(Icons.person,
                  color: Colors.orange, size: isMobile ? 16 : 20),
              const SizedBox(width: 8),
              Text(
                'Khách hàng mới',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_recentCustomers.isEmpty)
            Center(
              child: Text(
                'Không có khách hàng mới',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isMobile ? 12 : 14,
                ),
              ),
            )
          else
            ...(_recentCustomers
                .map((cust) => _buildCustomerItem(cust, isMobile))),
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

  Widget _buildCustomerItem(Customer customer, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: isMobile ? 12 : 14,
            backgroundColor: Colors.orange,
            child: Text(
              customer.name[0].toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 10 : 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  customer.occupation,
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
        return AppColors.primary;
      case AppointmentStatus.completed:
        return AppColors.success;
      case AppointmentStatus.cancelled:
        return AppColors.error;
    }
  }
}

// Lightweight sparkline chart (top-level)
class MiniLineChart extends StatelessWidget {
  final List<double> data;
  final Color strokeColor;
  final Color fillColor;
  const MiniLineChart(
      {super.key,
      required this.data,
      required this.strokeColor,
      required this.fillColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MiniLineChartPainter(data, strokeColor, fillColor),
      size: Size.infinite,
    );
  }
}

class _MiniLineChartPainter extends CustomPainter {
  final List<double> data;
  final Color strokeColor;
  final Color fillColor;
  _MiniLineChartPainter(this.data, this.strokeColor, this.fillColor);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxV = data.reduce((a, b) => a > b ? a : b);
    final minV = data.reduce((a, b) => a < b ? a : b);
    final range = (maxV - minV).abs() < 1e-6 ? 1.0 : (maxV - minV);

    final path = Path();
    final fillPath = Path();
    final dx = size.width / (data.length - 1);
    for (int i = 0; i < data.length; i++) {
      final x = i * dx;
      final norm = (data[i] - minV) / range;
      final y = size.height - norm * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = fillColor;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = strokeColor
      ..isAntiAlias = true;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _MiniLineChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.fillColor != fillColor;
  }
}

// Lightweight vertical bar chart (top-level)
class MiniBarChart extends StatelessWidget {
  final List<String> labels;
  final List<double> values;
  final Color barColor;
  const MiniBarChart(
      {super.key,
      required this.labels,
      required this.values,
      required this.barColor});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final maxV =
          values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);
      final barW = (c.maxWidth / (values.length * 2)).clamp(6.0, 24.0);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(values.length, (i) {
          final h = maxV <= 0 ? 0.0 : (values[i] / maxV) * (c.maxHeight - 24);
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: barW,
                height: h,
                decoration: BoxDecoration(
                  color: barColor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: barW * 2,
                child: Text(
                  labels.length > i ? labels[i] : '',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }),
      );
    });
  }
}

class _BarItem {
  final String label;
  final double value;
  _BarItem(this.label, this.value);
}
