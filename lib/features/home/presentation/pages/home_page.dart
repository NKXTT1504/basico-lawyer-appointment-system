import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/hero_section.dart';
import '../widgets/feature_cards.dart';
import '../widgets/testimonials_section.dart';
import '../../../appointment/domain/entities/appointment.dart';
import '../../../appointment/data/datasources/appointment_local_data_source.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeTab();
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const HeroSection(),
              const FeatureCards(),
              _WhyChooseSection(),
              _HowItWorksSection(),
              const TestimonialsSection(),
              _CTASection(),
              // Footer section
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05, // 5% of screen width
                  vertical: screenHeight * 0.03, // 3% of screen height
                ),
                color: const Color(0xFF1E3A8A),
                child: Column(
                  children: [
                    Text(
                      'BASICO LAW FIRM',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045, // 4.5% of screen width
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                        height: screenHeight * 0.015), // 1.5% of screen height
                    Text(
                      'Giải pháp pháp lý chuyên nghiệp cho mọi nhu cầu',
                      style: TextStyle(
                        fontSize: screenWidth * 0.03, // 3% of screen width
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                        height: screenHeight * 0.02), // 2% of screen height
                    Text(
                      '© 2025 Basico Law Firm. Tất cả quyền được bảo lưu.',
                      style: TextStyle(
                        fontSize: screenWidth * 0.025, // 2.5% of screen width
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

class _WhyChooseSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vì sao chọn Basico?',
              style: TextStyle(
                  fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _bullet('Luật sư giàu kinh nghiệm, chuyên môn đa lĩnh vực'),
          _bullet('Đặt lịch nhanh, xác nhận tức thì'),
          _bullet('Chi phí minh bạch, báo giá rõ ràng'),
        ],
      ),
    );
  }

  Widget _bullet(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [const Text('•  '), Expanded(child: Text(text))]),
      );
}

class _HowItWorksSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quy trình 3 bước',
              style: TextStyle(
                  fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _step(1, 'Chọn luật sư phù hợp'),
          _step(2, 'Chọn ngày/giờ trống'),
          _step(3, 'Xác nhận và theo dõi lịch hẹn'),
        ],
      ),
    );
  }

  Widget _step(int n, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          CircleAvatar(radius: 12, child: Text('$n')),
          const SizedBox(width: 8),
          Expanded(child: Text(text))
        ]),
      );
}

class _CTASection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      margin:
          EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cần hỗ trợ ngay?',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
              'Liên hệ đội ngũ của chúng tôi để được tư vấn nhanh chóng.',
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pushNamed('/services'),
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white)),
              child: const Text('Khám phá dịch vụ',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
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
  final AppointmentLocalDataSource _dataSource =
      AppointmentLocalDataSourceImpl();
  // ignore: unused_field
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth *
                (isTablet ? 0.08 : 0.04), // 8% for tablet, 4% for mobile
            vertical: screenHeight * 0.02, // 2% of screen height
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Title
              _buildPageTitle(),
              SizedBox(height: screenHeight * 0.03), // 3% of screen height

              // Tabs
              _buildTabs(),
              SizedBox(height: screenHeight * 0.03), // 3% of screen height

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Text(
      'LỊCH HẸN CỦA BẠN',
      style: TextStyle(
        fontSize: screenWidth *
            (isTablet ? 0.07 : 0.06), // 7% for tablet, 6% for mobile
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1C1B1F),
      ),
    );
  }

  Widget _buildTabs() {
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTab(
            text: 'Cuộc hẹn sắp tới',
            index: 0,
            isSelected: _selectedTabIndex == 0,
          ),
          SizedBox(width: screenWidth * 0.04), // 4% of screen width
          _buildTab(
            text: 'Lịch sử cuộc hẹn',
            index: 1,
            isSelected: _selectedTabIndex == 1,
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String text,
    required int index,
    required bool isSelected,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth *
              (isTablet ? 0.08 : 0.05), // 8% for tablet, 5% for mobile
          vertical: screenHeight * 0.015, // 1.5% of screen height
        ),
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
            fontSize: screenWidth *
                (isTablet ? 0.04 : 0.035), // 4% for tablet, 3.5% for mobile
            color: isSelected ? Colors.white : const Color(0xFF1C1B1F),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentTable() {
    final appointments =
        _selectedTabIndex == 0 ? _upcomingAppointments : _historyAppointments;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

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
          // Table Header - only show on larger screens
          if (isTablet) _buildTableHeader(),
          // Table Body
          Expanded(
            child: appointments.isEmpty
                ? _buildEmptyState()
                : isTablet
                    ? ListView.builder(
                        itemCount: appointments.length,
                        itemBuilder: (context, index) {
                          return _buildTableRow(appointments[index], index);
                        },
                      )
                    : _buildMobileAppointmentList(appointments),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Text(
      text,
      style: TextStyle(
        fontSize: screenWidth * 0.028, // 2.8% of screen width
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

  Widget _buildMobileAppointmentList(List<Appointment> appointments) {
    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        return _buildMobileAppointmentCard(appointments[index], index);
      },
    );
  }

  Widget _buildMobileAppointmentCard(Appointment appointment, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.all(screenWidth * 0.02), // 2% of screen width
      padding: EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Expanded(
                child: Text(
                  appointment.lawyerName,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04, // 4% of screen width
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1C1B1F),
                  ),
                ),
              ),
              _buildStatusCell(appointment.status),
            ],
          ),
          SizedBox(height: screenHeight * 0.01), // 1% of screen height
          Text(
            'Thời gian: ${appointment.time}',
            style: TextStyle(
              fontSize: screenWidth * 0.035, // 3.5% of screen width
              color: Colors.grey[600],
            ),
          ),
          Text(
            'Ngày: ${appointment.dayOfWeek}, ${appointment.date}',
            style: TextStyle(
              fontSize: screenWidth * 0.035, // 3.5% of screen width
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: screenHeight * 0.01), // 1% of screen height
          Text(
            'Dịch vụ: ${appointment.service}',
            style: TextStyle(
              fontSize: screenWidth * 0.035, // 3.5% of screen width
              color: Colors.grey[600],
            ),
          ),
          if (appointment.action != null) ...[
            SizedBox(height: screenHeight * 0.01), // 1% of screen height
            Text(
              'Thao tác: ${appointment.action}',
              style: TextStyle(
                fontSize: screenWidth * 0.035, // 3.5% of screen width
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
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

// Removed unused _LawyersTab and _ProfilePlaceholder widgets
