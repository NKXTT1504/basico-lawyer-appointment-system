import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/appointment.dart';
import '../../data/datasources/appointment_local_data_source.dart';
import '../widgets/appointment_table.dart';
import '../widgets/appointment_tabs.dart';

class AppointmentListPage extends StatefulWidget {
  const AppointmentListPage({super.key});

  @override
  State<AppointmentListPage> createState() => _AppointmentListPageState();
}

class _AppointmentListPageState extends State<AppointmentListPage> {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * (isTablet ? 0.08 : 0.04), // 8% for tablet, 4% for mobile
            vertical: screenHeight * 0.02, // 2% of screen height
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Title
              _buildPageTitle(),
              SizedBox(height: screenHeight * 0.03), // 3% of screen height
              
              // Tabs
              AppointmentTabs(
                selectedIndex: _selectedTabIndex,
                onTabChanged: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
              ),
              SizedBox(height: screenHeight * 0.03), // 3% of screen height
              
              // Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : AppointmentTable(
                        appointments: _selectedTabIndex == 0 
                            ? _upcomingAppointments 
                            : _historyAppointments,
                      ),
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
        fontSize: screenWidth * (isTablet ? 0.07 : 0.06), // 7% for tablet, 6% for mobile
        fontWeight: FontWeight.bold,
        color: AppColors.onBackground,
      ),
    );
  }
}
