import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../widgets/header_widget.dart';
import '../widgets/hero_section.dart';
import '../widgets/feature_cards.dart';
import '../../../appointment/domain/entities/appointment.dart';
import '../../../appointment/data/datasources/appointment_local_data_source.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomeTab(),
    const _AppointmentsTab(),
    const _LawyersTab(),
    const _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1E3A8A),
          unselectedItemColor: Colors.grey[600],
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 20.sp),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today, size: 20.sp),
              label: 'Lịch hẹn',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people, size: 20.sp),
              label: 'Luật sư',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 20.sp),
              label: 'Cá nhân',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderWidget(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const HeroSection(),
              const FeatureCards(),
              // Footer section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                color: const Color(0xFF1E3A8A),
                child: Column(
                  children: [
                    Text(
                      'BASICO LAW FIRM',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Giải pháp pháp lý chuyên nghiệp cho mọi nhu cầu',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      '© 2024 Basico Law Firm. Tất cả quyền được bảo lưu.',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.white60,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppointmentsTab extends StatefulWidget {
  const _AppointmentsTab();

  @override
  State<_AppointmentsTab> createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends State<_AppointmentsTab> {
  final AppointmentLocalDataSource _dataSource = AppointmentLocalDataSourceImpl();
  List<Appointment> _appointments = [];
  List<Appointment> _upcomingAppointments = [];
  List<Appointment> _historyAppointments = [];
  bool _isLoading = true;
  int _selectedTabIndex = 1; // Default to history tab

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appointments = await _dataSource.getAppointments();
      final upcoming = await _dataSource.getUpcomingAppointments();
      final history = await _dataSource.getAppointmentHistory();

      setState(() {
        _appointments = appointments;
        _upcomingAppointments = upcoming;
        _historyAppointments = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Title
              _buildPageTitle(),
              SizedBox(height: 24.h),
              
              // Tabs
              _buildTabs(),
              SizedBox(height: 24.h),
              
              // Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildAppointmentTable(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageTitle() {
    return Text(
      'LỊCH HẸN CỦA BẠN',
      style: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1C1B1F),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        _buildTab(
          text: 'Cuộc hẹn sắp tới',
          index: 0,
          isSelected: _selectedTabIndex == 0,
        ),
        SizedBox(width: 16.w),
        _buildTab(
          text: 'Lịch sử cuộc hẹn',
          index: 1,
          isSelected: _selectedTabIndex == 1,
        ),
      ],
    );
  }

  Widget _buildTab({
    required String text,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey.shade300,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            color: isSelected ? Colors.white : const Color(0xFF1C1B1F),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentTable() {
    final appointments = _selectedTabIndex == 0 ? _upcomingAppointments : _historyAppointments;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Header
          _buildTableHeader(),
          // Table Body
          Expanded(
            child: appointments.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      return _buildTableRow(appointments[index], index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A8A), // Dark blue
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildHeaderCell('LUẬT SƯ'),
          ),
          Expanded(
            flex: 2,
            child: _buildHeaderCell('NGÀY'),
          ),
          Expanded(
            flex: 2,
            child: _buildHeaderCell('DỊCH VỤ'),
          ),
          Expanded(
            flex: 1,
            child: _buildHeaderCell('TRẠNG THÁI'),
          ),
          Expanded(
            flex: 1,
            child: _buildHeaderCell('THAO TÁC'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11.sp,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildTableRow(Appointment appointment, int index) {
    final isEven = index % 2 == 0;
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildDataCell(appointment.lawyerName),
          ),
          Expanded(
            flex: 2,
            child: _buildDataCell(
              '${appointment.time}\n${appointment.dayOfWeek}, ${appointment.date}',
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildDataCell(appointment.service),
          ),
          Expanded(
            flex: 1,
            child: _buildStatusCell(appointment.status),
          ),
          Expanded(
            flex: 1,
            child: _buildDataCell(appointment.action ?? '-'),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        color: const Color(0xFF1C1B1F),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildStatusCell(AppointmentStatus status) {
    Color statusColor;
    switch (status) {
      case AppointmentStatus.completed:
        statusColor = const Color(0xFF4CAF50); // Green
        break;
      case AppointmentStatus.cancelled:
        statusColor = const Color(0xFFF44336); // Red
        break;
      case AppointmentStatus.confirmed:
        statusColor = const Color(0xFF2196F3); // Blue
        break;
      case AppointmentStatus.pending:
        statusColor = const Color(0xFFFFA726); // Orange
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 10.sp,
          color: statusColor,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Không có dữ liệu',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LawyersTab extends StatelessWidget {
  const _LawyersTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Luật sư'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Danh sách luật sư - Sẽ được phát triển'),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cá nhân'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Thông tin cá nhân - Sẽ được phát triển'),
      ),
    );
  }
}
