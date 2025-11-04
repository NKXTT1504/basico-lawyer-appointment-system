import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../data/services/user_storage_service.dart';
import '../../data/models/admin_user.dart';
import '../../data/models/appointment.dart';
import '../../data/services/admin_api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/page_header.dart';

class LawyerAppointmentsPage extends StatefulWidget {
  const LawyerAppointmentsPage({super.key});

  @override
  State<LawyerAppointmentsPage> createState() => _LawyerAppointmentsPageState();
}

class _LawyerAppointmentsPageState extends State<LawyerAppointmentsPage> {
  List<Appointment> _myAppointments = [];
  bool _isLoading = true;
  String _selectedStatus = 'all';
  // Keep services (as joined string) by appointment id to satisfy backend update requirements
  final Map<String, String> _servicesByAppointmentId = <String, String>{};
  final AdminApiService _adminApiService = AdminApiService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await UserStorageService.getCurrentUser();
      if (user != null && user.role == UserRole.lawyer) {
        // Try backend first
        try {
          print('🔍 Loading lawyer appointments from API...');
          print('👤 Current user email: ${user.email}');

          // 1) Resolve lawyerId from Users API (UserWithLawyerProfile only-lawyers)
          final api = AdminApiService();
          print('📡 Fetching lawyer profiles...');
          final resp = await api.getUsersWithLawyerProfileOnly();

          print('📊 API Response Status: ${resp.statusCode}');
          print('📊 API Response Data: ${resp.data}');

          final Map<String, dynamic> body = resp.data is Map<String, dynamic>
              ? resp.data as Map<String, dynamic>
              : <String, dynamic>{};
          final List list = (body['result'] ?? body['Result'] ?? []) as List;

          print('📋 Found ${list.length} lawyer profiles');

          final Map<String, dynamic>? me = list
              .map((e) => Map<String, dynamic>.from(e as Map))
              .firstWhere((e) {
            final userData = e['user'] as Map<String, dynamic>? ?? {};
            final email = (userData['email'] ?? '').toString().toLowerCase();
            print(
                '🔍 Checking email: $email vs current: ${user.email.toLowerCase()}');
            return email == user.email.toLowerCase();
          }, orElse: () => <String, dynamic>{});

          if (me == null || me.isEmpty) {
            print('❌ Không tìm thấy hồ sơ luật sư cho email: ${user.email}');
            throw 'Không tìm thấy hồ sơ luật sư';
          }

          print('✅ Found lawyer profile: $me');

          final int lawyerId =
              int.tryParse((me['lawyerProfile']?['id'] ?? '').toString()) ?? -1;
          if (lawyerId <= 0) {
            print('❌ Không tìm thấy mã luật sư từ profile');
            throw 'Không tìm thấy mã luật sư';
          }

          print('✅ Lawyer ID: $lawyerId');

          // 2) Fetch all appointments and filter by lawyerId
          print('📡 Fetching all appointments...');
          final aptsResp = await api.getAppointmentsJoined();

          print('📊 Appointments Response Status: ${aptsResp.statusCode}');
          print('📊 Appointments Response Data: ${aptsResp.data}');
          final List<dynamic> apts = aptsResp.data is List
              ? aptsResp.data as List
              : ((aptsResp.data is Map &&
                      ((aptsResp.data as Map)['result'] is List))
                  ? ((aptsResp.data as Map)['result'] as List)
                  : <dynamic>[]);

          // Filter appointments by lawyerId
          final filteredApts = apts.where((apt) {
            final aptLawyerId =
                int.tryParse((apt['lawyerId'] ?? '').toString()) ?? -1;
            return aptLawyerId == lawyerId;
          }).toList();

          print(
              '📋 Found ${filteredApts.length} appointments for lawyer $lawyerId');

          final appointments = filteredApts.map<Appointment>((raw) {
            final Map<String, dynamic> e = Map<String, dynamic>.from(raw);
            final Map<String, dynamic> userJson =
                Map<String, dynamic>.from((e['user'] ?? {}) as Map);
            // Cache services for later update
            final List<dynamic> servicesList =
                (e['services'] is List) ? (e['services'] as List) : <dynamic>[];
            final String servicesJoined = servicesList
                .map((s) => s.toString())
                .where((s) => s.trim().isNotEmpty)
                .join(', ');
            final String aptId =
                (e['id'] ?? e['appointmentId'] ?? '').toString();
            _servicesByAppointmentId[aptId] = servicesJoined;
            return Appointment(
              id: aptId,
              customerId: (e['userId'] ?? '').toString(),
              customerName: (userJson['fullName'] ?? '').toString(),
              lawyerId: (e['lawyerId'] ?? '').toString(),
              lawyerName: 'Luật sư #${(e['lawyerId'] ?? '').toString()}',
              appointmentDate:
                  DateTime.tryParse((e['scheduledAt'] ?? '').toString()) ??
                      DateTime.now(),
              timeSlot: (e['slot'] ?? '').toString(),
              duration: '60m',
              type: (e['spec'] ?? '').toString(),
              description:
                  ((e['services'] is List && (e['services'] as List).isNotEmpty)
                          ? (e['services'] as List).first.toString()
                          : '')
                      .toString(),
              status: _parseStatusFromInt(e['status']),
              notes: (e['note'] ?? '').toString(),
              fee: ((e['lawyerProfile']?['pricePerHour'] ?? 0) as num)
                  .toDouble(),
              createdAt: DateTime.tryParse((e['createAt'] ?? '').toString()) ??
                  DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }).toList();

          print('✅ Successfully parsed ${appointments.length} appointments');

          setState(() {
            _myAppointments = appointments;
            _isLoading = false;
          });
        } catch (e) {
          print('❌ Error loading from API: $e');
          print('📦 Falling back to local storage...');
          // Fallback to local storage
          final lawyers = await UserStorageService.getLawyers();
          final lawyerProfile = lawyers.firstWhere(
              (l) => l.email.toLowerCase() == user.email.toLowerCase(),
              orElse: () => throw 'Không tìm thấy hồ sơ luật sư');
          final appointments =
              await UserStorageService.getLawyerAppointments(lawyerProfile.id);
          setState(() {
            _myAppointments = appointments;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          // Redirect non-lawyer to home/dashboard
          _isLoading = false;
          context.go('/home');
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Có lỗi xảy ra: $e');
    }
  }

  AppointmentStatus _parseStatusFromInt(dynamic v) {
    final intVal = (v is int) ? v : int.tryParse(v?.toString() ?? '') ?? -1;
    switch (intVal) {
      case 0:
        return AppointmentStatus.pending;
      case 1:
        return AppointmentStatus.confirmed;
      case 2:
        return AppointmentStatus.completed;
      case 3:
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.pending;
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _updateAppointmentStatus(
      Appointment appointment, AppointmentStatus newStatus) async {
    try {
      final int id = int.parse(appointment.id);
      if (newStatus == AppointmentStatus.confirmed) {
        await _adminApiService.confirmAppointment(id);
      } else if (newStatus == AppointmentStatus.cancelled) {
        await _adminApiService.cancelAppointment(id);
      } else if (newStatus == AppointmentStatus.completed) {
        try {
          await _adminApiService.completeAppointment(id);
        } on DioException catch (e) {
          // Ghi log chi tiết để debug
          // ignore: avoid_print
          print('⚠️ completeAppointment failed: status=' +
              (e.response?.statusCode?.toString() ?? 'null') +
              ' data=' +
              (e.response?.data?.toString() ?? 'null'));

          // Fallback: dùng UpdateAppointment với các trường bắt buộc
          final servicesStr = _servicesByAppointmentId[appointment.id] ?? '';
          final services = servicesStr.isEmpty
              ? <String>[]
              : servicesStr
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();
          final updateData = {
            'status': 2,
            'Slot': appointment.timeSlot,
            'Spec': appointment.type,
            'Services': services,
          };
          await _adminApiService.updateAppointment(id, updateData);
        }
      } else {
        return;
      }

      await _loadData();
      _showSuccessSnackBar('Cập nhật trạng thái thành công');
    } catch (e) {
      _showErrorSnackBar('Có lỗi xảy ra: $e');
    }
  }

  // Removed status-int helper (no longer needed with dedicated endpoints)

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return AppColors.warning;
      case AppointmentStatus.confirmed:
        return AppColors.primary;
      case AppointmentStatus.completed:
        return AppColors.success;
      case AppointmentStatus.cancelled:
        return AppColors.error;
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

  List<Appointment> get _filteredAppointments {
    if (_selectedStatus == 'all') {
      return _myAppointments;
    }
    return _myAppointments
        .where((apt) => apt.status.name == _selectedStatus)
        .toList();
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
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      body: Column(
        children: [
          PageHeader(
            title: 'Lịch hẹn của tôi',
            subtitle: 'Quản lý và cập nhật trạng thái các cuộc hẹn',
            actions: [
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 10 : 12, vertical: isMobile ? 6 : 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Tổng: ${_myAppointments.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Filter chips
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tất cả', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Chờ xác nhận', 'pending'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Đã xác nhận', 'confirmed'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Hoàn thành', 'completed'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Đã hủy', 'cancelled'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Appointments list
          Expanded(
            child: _filteredAppointments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: isMobile ? 48 : 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có lịch hẹn nào',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(isMobile ? 12 : 16),
                    itemCount: _filteredAppointments.length,
                    itemBuilder: (context, index) {
                      final appointment = _filteredAppointments[index];
                      return _buildAppointmentCard(appointment);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // removed old stat item (header replaced by PageHeader)

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = value;
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
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
                        style: TextStyle(
                          fontSize: isMobile ? 15 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment.description,
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 8 : 12,
                      vertical: isMobile ? 4 : 6),
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
                      fontSize: isMobile ? 10 : 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(appointment.status),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: isMobile ? 10 : 12),

            // Details
            if (isMobile) ...[
              // Mobile layout - stacked
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    '${appointment.appointmentDate.day}/${appointment.appointmentDate.month}/${appointment.appointmentDate.year}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    appointment.timeSlot,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ] else ...[
              // Desktop layout - inline
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
            ],

            const SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.attach_money,
                    size: isMobile ? 14 : 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '${appointment.fee.toStringAsFixed(0)} VNĐ',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 13 : 14,
                  ),
                ),
              ],
            ),

            if (appointment.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note,
                      size: isMobile ? 14 : 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment.notes,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isMobile ? 13 : 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: isMobile ? 12 : 16),

            // Actions
            if (appointment.status == AppointmentStatus.pending) ...[
              if (isMobile) ...[
                // Mobile layout - stacked buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _updateAppointmentStatus(
                        appointment, AppointmentStatus.confirmed),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Chấp nhận'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _updateAppointmentStatus(
                        appointment, AppointmentStatus.cancelled),
                    icon: const Icon(Icons.cancel, size: 16),
                    label: const Text('Từ chối'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ] else ...[
                // Desktop layout - inline buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateAppointmentStatus(
                            appointment, AppointmentStatus.confirmed),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Chấp nhận'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
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
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],

            if (appointment.status == AppointmentStatus.confirmed) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _updateAppointmentStatus(
                      appointment, AppointmentStatus.completed),
                  icon: const Icon(Icons.done, size: 16),
                  label: const Text('Hoàn thành'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
