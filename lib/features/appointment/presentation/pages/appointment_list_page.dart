import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/appointment.dart';
// import '../../data/datasources/appointment_local_data_source.dart';
import '../../../../core/services/appointment_sync_service.dart';
import '../widgets/appointment_table.dart';
import '../widgets/appointment_tabs.dart';
import '../../data/services/appointment_api_service.dart';
import '../../../admin/data/services/user_storage_service.dart';
import '../../../lawyer/data/services/lawyer_api_service.dart';
import 'appointment_confirmation_page.dart';

class AppointmentListPage extends StatefulWidget {
  const AppointmentListPage({super.key});

  @override
  State<AppointmentListPage> createState() => _AppointmentListPageState();
}

class BookingPage extends StatefulWidget {
  final String lawyerId;
  final String lawyerName;
  final List<String> services;
  const BookingPage(
      {super.key,
      required this.lawyerId,
      required this.lawyerName,
      required this.services});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedSlot;
  bool _loading = false;
  Set<String> _occupied = <String>{};
  double? _hourlyRate;

  static const List<String> _slots = <String>[
    '08:00 - 10:00',
    '10:00 - 12:00',
    '13:00 - 15:00',
    '15:00 - 17:00',
  ];

  @override
  void initState() {
    super.initState();
    _loadOccupied();
    _loadLawyerProfile();
  }

  Future<void> _loadLawyerProfile() async {
    try {
      final response = await LawyerApiService.getLawyerById(widget.lawyerId);
      if (response.statusCode == 200) {
        final data = response.data;
        final profile =
            data is Map<String, dynamic> ? (data['result'] ?? data) : data;
        if (profile is Map<String, dynamic>) {
          setState(() {
            _hourlyRate = (profile['pricePerHour'] ??
                profile['hourlyRate'] ??
                0) as double?;
          });
        }
      }
    } catch (e) {
      print('Failed to load lawyer profile: $e');
    }
  }

  double _calculateDeposit() {
    if (_hourlyRate == null || _selectedSlot == null) return 0;
    // Extract hours from slot: "08:00 - 10:00" -> 2 hours
    final parts = _selectedSlot!.split(' - ');
    if (parts.length != 2) return 0;
    try {
      final start = parts[0].split(':');
      final end = parts[1].split(':');
      final startHour = int.parse(start[0]);
      final startMin = int.parse(start[1]);
      final endHour = int.parse(end[0]);
      final endMin = int.parse(end[1]);
      final startTime = startHour + startMin / 60.0;
      final endTime = endHour + endMin / 60.0;
      final hours = endTime - startTime;
      // Deposit = (hourlyRate × hours) × 30%
      return (_hourlyRate! * hours) * 0.3;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _loadOccupied() async {
    final set = await AppointmentSyncService.getOccupiedTimeSlots(
      lawyerId: widget.lawyerId,
      date: _selectedDate,
    );
    setState(() => _occupied = set);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _selectedSlot = null;
      });
      await _loadOccupied();
    }
  }

  Future<void> _confirm() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn khung giờ')),
      );
      return;
    }

    final currentUser = await UserStorageService.getCurrentUser();
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để đặt lịch')),
      );
      return;
    }

    // Nếu có 2+ dịch vụ, chuyển sang bước xác nhận & thanh toán
    if (widget.services.length >= 2) {
      final deposit = _calculateDeposit();
      if (deposit <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Không thể tính phí đặt cọc. Vui lòng thử lại.')),
        );
        return;
      }
      // Navigate to confirmation & payment page
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AppointmentConfirmationPage(
            lawyerId: widget.lawyerId,
            lawyerName: widget.lawyerName,
            services: widget.services,
            selectedDate: _selectedDate,
            selectedSlot: _selectedSlot!,
            depositAmount: deposit,
            hourlyRate: _hourlyRate ?? 0,
          ),
        ),
      );
      return;
    }

    // Nếu chỉ 1 dịch vụ, đặt lịch trực tiếp
    setState(() => _loading = true);
    try {
      final appointmentData = {
        'userId': currentUser.id,
        'lawyerId': widget.lawyerId,
        'scheduledAt': _selectedDate.toIso8601String(),
        'slot': _selectedSlot!,
        'spec': widget.services.isEmpty ? '' : widget.services.join(', '),
        'services': widget.services,
        'note': 'Đặt lịch từ mobile app',
      };

      final response =
          await AppointmentApiService.createAppointment(appointmentData);

      // Debug logging
      print('Appointment creation response status: ${response.statusCode}');
      print('Appointment creation response data: ${response.data}');

      if (response.statusCode == 200) {
        // Handle different response formats
        final responseData = response.data;
        bool isSuccess = false;

        if (responseData is Map<String, dynamic>) {
          isSuccess = responseData['success'] == true ||
              responseData['isSuccess'] == true ||
              responseData['Success'] == true;
        } else {
          // If response is not a map, consider it successful if status is 200
          isSuccess = true;
        }

        if (isSuccess) {
          setState(() => _loading = false);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đặt lịch thành công')),
          );
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/appointments');
          }
          return;
        }
      }
    } catch (e) {
      print('API booking failed, falling back to local: $e');
    }

    // Fallback to local storage
    try {
      final ok = await AppointmentSyncService.createBookingForLawyerMulti(
        lawyerId: widget.lawyerId,
        lawyerName: widget.lawyerName,
        services: widget.services,
        date: _selectedDate,
        timeSlot: _selectedSlot!,
      );
      if (!mounted) return;
      setState(() => _loading = false);
      if (ok) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đặt lịch thành công')),
        );
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/appointments');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Khung giờ đã có người đặt')),
        );
        await _loadOccupied();
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi đặt lịch: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn ngày và giờ'),
      ),
      body: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Luật sư: ${widget.lawyerName}',
                style: TextStyle(
                    fontSize: isTablet ? 18 : 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Dịch vụ: ${widget.services.join(', ')}',
                style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _slots.map((s) {
                final disabled = _occupied.contains(s);
                final selected = _selectedSlot == s;
                return ChoiceChip(
                  label: Text(s),
                  selected: selected,
                  onSelected: disabled
                      ? null
                      : (_) => setState(() => _selectedSlot = s),
                  selectedColor: const Color(0xFF1E3A8A),
                  labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black87),
                  disabledColor: Colors.grey.shade300,
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _confirm,
                child: _loading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Xác nhận đặt lịch'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// === Đã loại bỏ BookingSheet, _BookingSheetState, và openBookingSheet (booking dạng cũ 1-1 lawyer/service) ===

class _AppointmentListPageState extends State<AppointmentListPage> {
  // Data now loaded via sync service; keep fields for UI state only
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
      // Get current user
      final currentUser = await UserStorageService.getCurrentUser();
      if (currentUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Try to load from API first
      try {
        final response = await AppointmentApiService.getAllAppointments();
        if (response.statusCode == 200) {
          // Handle different API response formats
          final responseData = response.data;

          List<dynamic> appointmentsData;
          if (responseData is List) {
            appointmentsData = responseData;
          } else if (responseData is Map<String, dynamic>) {
            // Check for common response wrapper keys
            final dynamic data = responseData['data'] ??
                responseData['result'] ??
                responseData['appointments'];
            appointmentsData = data is List ? data : <dynamic>[];
          } else {
            appointmentsData = [];
          }

          // Debug: Log current user info
          print('🔍 Current User Info:');
          print('  ID: ${currentUser.id}');
          print('  Email: ${currentUser.email}');
          print('📊 Total appointments from API: ${appointmentsData.length}');

          // Parse the JSON to check userId before creating Appointment objects
          // Match by email since backend userId might be different from local ID
          final List<Map<String, dynamic>> filteredJson = [];

          for (var json in appointmentsData) {
            final customerEmail = json['user']?['email']?.toString();
            print(
                '🔍 Checking appointment - Email: $customerEmail, Current: ${currentUser.email}');

            final matches =
                customerEmail?.toLowerCase() == currentUser.email.toLowerCase();
            print('  Match: $matches');

            if (matches) {
              filteredJson.add(json);
            }
          }

          print('✅ Found ${filteredJson.length} appointments for current user');

          final appointments = filteredJson
              .map((json) {
                try {
                  return Appointment.fromJson(json);
                } catch (e) {
                  print('❌ Error parsing appointment: $e');
                  print('   JSON: $json');
                  return null;
                }
              })
              .where((apt) => apt != null)
              .cast<Appointment>()
              .toList();

          print('✅ Successfully parsed ${appointments.length} appointments');

          final upcoming = appointments
              .where((a) =>
                  a.status == AppointmentStatus.confirmed ||
                  a.status == AppointmentStatus.pending)
              .toList();
          final history = appointments
              .where((a) =>
                  a.status == AppointmentStatus.completed ||
                  a.status == AppointmentStatus.cancelled)
              .toList();

          setState(() {
            _appointments = appointments;
            _upcomingAppointments = upcoming;
            _historyAppointments = history;
            _isLoading = false;
          });
          return;
        }
      } catch (e) {
        print('API load failed, falling back to local storage: $e');
      }

      // Fallback to local storage
      final list =
          await AppointmentSyncService.getHomeAppointmentsForCurrentCustomer();
      final appointments = list;
      final upcoming = list
          .where((a) =>
              a.status == AppointmentStatus.confirmed ||
              a.status == AppointmentStatus.pending)
          .toList();
      final history = list
          .where((a) =>
              a.status == AppointmentStatus.completed ||
              a.status == AppointmentStatus.cancelled)
          .toList();

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
                        onBookAppointment: () async {
                          // Điều hướng tới ServiceFieldSelectionPage (chọn lĩnh vực & dịch vụ) dùng GoRouter
                          final result =
                              await context.push('/service-field-selection');
                          if (result != null && result is Map) {
                            if (!mounted) return;
                            context.push('/lawyer-selection', extra: {
                              'fields': result['fields'],
                              'services': result['services'],
                            });
                          }
                        },
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
        fontSize: screenWidth *
            (isTablet ? 0.07 : 0.06), // 7% for tablet, 6% for mobile
        fontWeight: FontWeight.bold,
        color: AppColors.onBackground,
      ),
    );
  }
}

// ======================= PaymentSuccessPage =========================
class PaymentSuccessPage extends StatefulWidget {
  const PaymentSuccessPage({super.key});
  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán thành công')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 88),
            SizedBox(height: 20),
            Text('Thanh toán cọc thành công!\nBạn sẽ được chuyển về trang chủ.',
                style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
