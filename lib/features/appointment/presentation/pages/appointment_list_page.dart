import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/appointment.dart';
// import '../../data/datasources/appointment_local_data_source.dart';
import '../../../../core/services/appointment_sync_service.dart';
import '../widgets/appointment_table.dart';
import '../widgets/appointment_tabs.dart';

class AppointmentListPage extends StatefulWidget {
  const AppointmentListPage({super.key});

  @override
  State<AppointmentListPage> createState() => _AppointmentListPageState();
}

class BookingPage extends StatefulWidget {
  final String lawyerId;
  final String lawyerName;
  final String service;
  const BookingPage(
      {super.key,
      required this.lawyerId,
      required this.lawyerName,
      required this.service});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedSlot;
  bool _loading = false;
  Set<String> _occupied = <String>{};

  static const List<String> _slots = <String>[
    '09:00 - 10:00',
    '10:00 - 11:00',
    '14:00 - 15:00',
    '15:00 - 16:00',
  ];

  @override
  void initState() {
    super.initState();
    _loadOccupied();
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
    if (_selectedSlot == null) return;
    setState(() => _loading = true);
    final ok = await AppointmentSyncService.createBookingForLawyer(
      lawyerId: widget.lawyerId,
      lawyerName: widget.lawyerName,
      service: widget.service,
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
      // Điều hướng về danh sách lịch hẹn thay vì pop để tránh trang trắng
      if (mounted) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacementNamed('/appointments');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khung giờ đã có người đặt')),
      );
      await _loadOccupied();
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
            Text('Dịch vụ: ${widget.service}',
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

class BookingSheet extends StatefulWidget {
  final String lawyerId;
  final String lawyerName;
  final String service;
  const BookingSheet(
      {super.key,
      required this.lawyerId,
      required this.lawyerName,
      required this.service});

  @override
  State<BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<BookingSheet> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedSlot;
  bool _loading = false;
  Set<String> _occupied = <String>{};

  static const List<String> _slots = <String>[
    '09:00 - 10:00',
    '10:00 - 11:00',
    '14:00 - 15:00',
    '15:00 - 16:00',
  ];

  @override
  void initState() {
    super.initState();
    _loadOccupied();
  }

  Future<void> _loadOccupied() async {
    final set = await AppointmentSyncService.getOccupiedTimeSlots(
      lawyerId: widget.lawyerId,
      date: _selectedDate,
    );
    if (!mounted) return;
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
    if (_selectedSlot == null) return;
    setState(() => _loading = true);
    final ok = await AppointmentSyncService.createBookingForLawyer(
      lawyerId: widget.lawyerId,
      lawyerName: widget.lawyerName,
      service: widget.service,
      date: _selectedDate,
      timeSlot: _selectedSlot!,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khung giờ đã có người đặt')),
      );
      await _loadOccupied();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Đặt lịch: ${widget.lawyerName}',
                    style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text('Dịch vụ: ${widget.service}',
                style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 16),
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

Future<void> openBookingSheet(BuildContext context,
    {required String lawyerId,
    required String lawyerName,
    required String service}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.45,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: BookingSheet(
              lawyerId: lawyerId, lawyerName: lawyerName, service: service),
        );
      },
    ),
  );
  if (result == true && context.mounted) {
    // Go to appointments page after success
    Navigator.of(context).pushReplacementNamed('/appointments');
  }
}

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
      // Show only current customer's appointments
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
