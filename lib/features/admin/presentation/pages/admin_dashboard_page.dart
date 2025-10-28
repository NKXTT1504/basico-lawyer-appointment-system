import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/user_storage_service.dart';
import '../../data/services/admin_api_service.dart';
import '../../data/models/admin_user.dart';
import '../../data/models/appointment.dart';
import '../../data/models/customer.dart';
import '../../data/models/lawyer.dart';
import '../../../../core/services/admin_report_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await UserStorageService.getCurrentUser();
      if (user != null && user.role == UserRole.admin) {
        // Load data from API
        final adminApi = AdminApiService();

        print('📡 Fetching dashboard data from API...');

        // Fetch data from API
        final customersResp = await adminApi.getCustomers();
        final lawyersResp = await adminApi.getUsersWithLawyerProfileOnly();
        final appointmentsResp = await adminApi.getAppointmentsJoined();

        print(
            '📊 API Status - Customers: ${customersResp.statusCode}, Lawyers: ${lawyersResp.statusCode}, Appointments: ${appointmentsResp.statusCode}');

        // Parse API responses
        final customersData = customersResp.data['result'] as List? ?? [];
        final lawyersData = lawyersResp.data['result'] as List? ?? [];
        final appointmentsData = appointmentsResp.data['result'] as List? ?? [];

        print(
            '📋 API Data - ${customersData.length} customers, ${lawyersData.length} lawyers, ${appointmentsData.length} appointments');

        // Convert to models with safe parsing
        final customers = customersData.map((json) {
          try {
            return Customer.fromJson(json);
          } catch (e) {
            print('❌ Customer parse error: $e');
            // Return a default customer to avoid breaking the UI
            return Customer(
              id: (json['id'] ?? '').toString(),
              name: (json['fullName'] ?? json['name'] ?? 'Unknown').toString(),
              email: (json['email'] ?? '').toString(),
              phone: (json['phoneNumber'] ?? json['phone'] ?? '').toString(),
              address: (json['address'] ?? '').toString(),
              dateOfBirth: DateTime.now(),
              gender: 'Không xác định',
              occupation: 'Không xác định',
              notes: '',
              isActive: true,
              createdAt: DateTime.now(),
            );
          }
        }).toList();

        final lawyers = lawyersData.map((json) {
          try {
            final userData = json['user'] as Map<String, dynamic>;
            return Lawyer.fromJson(userData);
          } catch (e) {
            print('❌ Lawyer parse error: $e');
            // Return a default lawyer
            return Lawyer(
              id: (json['user']?['id'] ?? '').toString(),
              name: (json['user']?['fullName'] ?? 'Unknown').toString(),
              email: (json['user']?['email'] ?? '').toString(),
              phone: (json['user']?['phoneNumber'] ?? '').toString(),
              address: '',
              specialization: '',
              licenseNumber: '',
              experienceYears: 0,
              hourlyRate: 0,
              createdAt: DateTime.now(),
            );
          }
        }).toList();

        final appointments = appointmentsData.map((json) {
          try {
            return Appointment.fromJson(json);
          } catch (e) {
            print('❌ Appointment parse error: $e');
            // Return a default appointment
            return Appointment(
              id: (json['id'] ?? '').toString(),
              customerId: (json['userId'] ?? '').toString(),
              customerName: (json['user']?['fullName'] ?? 'Unknown').toString(),
              lawyerId: (json['lawyerId'] ?? '').toString(),
              lawyerName: 'Luật sư #${json['lawyerId'] ?? ''}',
              appointmentDate: DateTime.now(),
              timeSlot: (json['slot'] ?? '').toString(),
              duration: '60m',
              type: (json['spec'] ?? '').toString(),
              description: '',
              status: AppointmentStatus.pending,
              notes: '',
              fee: 0,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }
        }).toList();

        print(
            '✅ Successfully parsed: ${customers.length} customers, ${lawyers.length} lawyers, ${appointments.length} appointments');

        // Calculate statistics
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

            // Statistics cards (re-computed via report service)
            Row(
              children: [
                Text(
                  'Thống kê tổng quan',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
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
                            size: 16, color: Colors.blue),
                        const SizedBox(width: 6),
                        Text(
                          '${_monthStart.month}/${_monthStart.year}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue),
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
                      Colors.green,
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

            // Revenue overview (moved to top KPIs)
            const SizedBox.shrink(),

            SizedBox(height: isMobile ? 20 : 24),

            // Recent activity
            _buildRecentActivitySection(isMobile),

            SizedBox(height: isMobile ? 20 : 24),

            // Quick actions
            Text(
              'Thao tác nhanh',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
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

  Widget _buildRecentActivitySection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hoạt động gần đây',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
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
        return Colors.blue;
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
    }
  }
}
