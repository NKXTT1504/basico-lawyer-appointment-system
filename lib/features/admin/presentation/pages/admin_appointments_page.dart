import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

// AppBar is managed globally in MainNavigation for mobile
import '../../data/services/user_storage_service.dart';
import '../../data/models/appointment.dart';
import '../../data/models/admin_user.dart';
import '../../../../core/services/appointment_sync_service.dart';
import '../../data/services/admin_api_service.dart';

class AdminAppointmentsPage extends StatefulWidget {
  const AdminAppointmentsPage({super.key});

  @override
  State<AdminAppointmentsPage> createState() => _AdminAppointmentsPageState();
}

class _AdminAppointmentsPageState extends State<AdminAppointmentsPage> {
  List<Appointment> _appointments = [];
  List<Appointment> _filteredAppointments = [];
  bool _isLoading = true;
  String _selectedStatus = 'all';
  String _searchQuery = '';
  DateTime? _selectedDate;
  String _selectedLawyer = 'all';
  // Extra display data mapped from joined payload
  final Map<String, String> _avatarByAppointmentId = {};
  final Map<String, String> _emailByAppointmentId = {};
  final Map<String, String> _phoneByAppointmentId = {};
  final Map<String, String> _specByAppointmentId = {};
  final Map<String, String> _servicesByAppointmentId = {};

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final current = await UserStorageService.getCurrentUser();
      if (current == null || current.role != UserRole.admin) {
        if (mounted)
          context.go(
              current?.role == UserRole.lawyer ? '/lawyer/dashboard' : '/home');
        return;
      }
      // Prefer backend join endpoint
      List<Appointment> appointments;
      try {
        final api = AdminApiService();
        final resp = await api.getAppointmentsJoined();
        final Map<String, dynamic> body = resp.data is Map<String, dynamic>
            ? resp.data as Map<String, dynamic>
            : <String, dynamic>{};
        final List list = (body['result'] ?? body['Result'] ?? []) as List;
        appointments = list.map<Appointment>((raw) {
          final Map<String, dynamic> e = Map<String, dynamic>.from(raw as Map);
          final String id = (e['id'] ?? e['appointmentId'] ?? '').toString();
          final Map<String, dynamic> user =
              Map<String, dynamic>.from((e['user'] ?? {}) as Map);
          final Map<String, dynamic> profile =
              Map<String, dynamic>.from((e['lawyerProfile'] ?? {}) as Map);

          // Collect extra fields for display
          _avatarByAppointmentId[id] = (profile['img'] ?? '').toString();
          _emailByAppointmentId[id] = (user['email'] ?? '').toString();
          _phoneByAppointmentId[id] = (user['phoneNumber'] ?? '').toString();
          _specByAppointmentId[id] = (e['spec'] ?? '').toString();
          if (e['services'] is List && (e['services'] as List).isNotEmpty) {
            _servicesByAppointmentId[id] =
                (e['services'] as List).map((s) => s.toString()).join(', ');
          }

          return Appointment(
            id: id,
            customerId: (e['userId'] ?? '0').toString(),
            customerName: (user['fullName'] ?? '').toString(),
            lawyerId: (e['lawyerId'] ?? profile['id'] ?? '0').toString(),
            lawyerName: 'Luật sư #${(e['lawyerId'] ?? profile['id'] ?? '').toString()}',
            appointmentDate: DateTime.tryParse((e['scheduledAt'] ?? '').toString()) ??
                DateTime.now(),
            timeSlot: (e['slot'] ?? '').toString(),
            duration: '60m',
            type: (e['spec'] ?? '').toString(),
            description: _servicesByAppointmentId[id] ?? '',
            status: _parseStatusFromInt(e['status']),
            notes: (e['note'] ?? '').toString(),
            fee: (profile['pricePerHour'] ?? 0).toDouble(),
            createdAt: DateTime.tryParse((e['createAt'] ?? '').toString()) ??
                DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }).toList();
      } catch (_) {
        appointments = await AppointmentSyncService.getAdminAppointments();
      }
      setState(() {
        _appointments = appointments;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Có lỗi xảy ra: $e');
    }
  }

  AppointmentStatus _parseStatus(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return AppointmentStatus.pending;
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
      case 'canceled':
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.pending;
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredAppointments = _appointments.where((appointment) {
        // Status filter
        if (_selectedStatus != 'all' &&
            appointment.status.name != _selectedStatus) {
          return false;
        }

        // Search filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          if (!appointment.customerName.toLowerCase().contains(query) &&
              !appointment.lawyerName.toLowerCase().contains(query) &&
              !appointment.description.toLowerCase().contains(query)) {
            return false;
          }
        }

        // Date filter
        if (_selectedDate != null) {
          final appointmentDate = appointment.appointmentDate;
          if (appointmentDate.year != _selectedDate!.year ||
              appointmentDate.month != _selectedDate!.month ||
              appointmentDate.day != _selectedDate!.day) {
            return false;
          }
        }

        // Lawyer filter
        if (_selectedLawyer != 'all' &&
            appointment.lawyerName != _selectedLawyer) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _updateAppointmentStatus(
      Appointment appointment, AppointmentStatus newStatus) async {
    try {
      // Validation logic for status transitions
      if (!_isValidStatusTransition(appointment.status, newStatus)) {
        _showErrorSnackBar(
            'Không thể chuyển từ ${_getStatusText(appointment.status)} sang ${_getStatusText(newStatus)}');
        return;
      }

      // Show confirmation dialog for critical status changes
      if (newStatus == AppointmentStatus.cancelled) {
        final confirmed = await _showStatusChangeConfirmation(
          'Xác nhận hủy lịch hẹn',
          'Bạn có chắc chắn muốn hủy lịch hẹn của ${appointment.customerName}?',
          'Hủy lịch hẹn',
        );
        if (!confirmed) return;
      } else if (newStatus == AppointmentStatus.completed) {
        final confirmed = await _showStatusChangeConfirmation(
          'Xác nhận hoàn thành',
          'Đánh dấu lịch hẹn của ${appointment.customerName} là hoàn thành?',
          'Hoàn thành',
        );
        if (!confirmed) return;
      }

      final updatedAppointment = appointment.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      await UserStorageService.updateAppointment(updatedAppointment);
      await _loadAppointments();

      // Show success message with specific status
      _showSuccessSnackBar('${_getStatusText(newStatus)} lịch hẹn thành công');
    } catch (e) {
      _showErrorSnackBar('Có lỗi xảy ra khi cập nhật: $e');
    }
  }

  bool _isValidStatusTransition(
      AppointmentStatus currentStatus, AppointmentStatus newStatus) {
    // Define valid status transitions
    switch (currentStatus) {
      case AppointmentStatus.pending:
        return newStatus == AppointmentStatus.confirmed ||
            newStatus == AppointmentStatus.cancelled;
      case AppointmentStatus.confirmed:
        return newStatus == AppointmentStatus.completed ||
            newStatus == AppointmentStatus.cancelled;
      case AppointmentStatus.completed:
        return false; // Cannot change from completed
      case AppointmentStatus.cancelled:
        return false; // Cannot change from cancelled
    }
  }

  Future<bool> _showStatusChangeConfirmation(
      String title, String message, String actionText) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  actionText == 'Hủy lịch hẹn' ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(actionText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _deleteAppointment(String id) async {
    try {
      await UserStorageService.deleteAppointment(id);
      await _loadAppointments();
      _showSuccessSnackBar('Xóa đặt lịch thành công');
    } catch (e) {
      _showErrorSnackBar('Có lỗi xảy ra: $e');
    }
  }

  void _showDeleteDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
            'Bạn có chắc chắn muốn xóa đặt lịch của ${appointment.customerName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAppointment(appointment.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  List<String> get _uniqueLawyers {
    return _appointments.map((apt) => apt.lawyerName).toSet().toList()..sort();
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return AppColors.warning;
      case AppointmentStatus.confirmed:
        return AppColors.info;
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
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Search and filters
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            color: AppColors.surface,
            child: Column(
              children: [
                // Search bar
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _applyFilters();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên khách hàng, luật sư...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _applyFilters();
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                ),

                const SizedBox(height: 12),

                // Filter chips
                SingleChildScrollView(
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

                const SizedBox(height: 12),

                // Advanced filters
                Row(
                  children: [
                    Expanded(
                      child: _buildDateFilter(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildLawyerFilter(),
                    ),
                  ],
                ),
              ],
            ),
          ),

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
                          color: AppColors.onSurfaceVariant.withOpacity(0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Không có đặt lịch nào',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            color: AppColors.onSurfaceVariant,
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

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = value;
          _applyFilters();
        });
      },
      backgroundColor: AppColors.surfaceVariant,
      selectedColor: AppColors.primaryContainer,
      checkmarkColor: AppColors.onPrimaryContainer,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
      ),
    );
  }

  Widget _buildDateFilter() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) {
          setState(() {
            _selectedDate = date;
            _applyFilters();
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outline),
          borderRadius: BorderRadius.circular(8),
          color: AppColors.surface,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, size: 16, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              _selectedDate != null
                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                  : 'Chọn ngày',
              style: TextStyle(
                fontSize: 12,
                color: _selectedDate != null ? AppColors.onSurface : AppColors.onSurfaceVariant,
              ),
            ),
            if (_selectedDate != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = null;
                    _applyFilters();
                  });
                },
                child: const Icon(Icons.clear, size: 16, color: AppColors.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLawyerFilter() {
    return DropdownButtonFormField<String>(
      value: _selectedLawyer,
      decoration: InputDecoration(
        labelText: 'Luật sư',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
      items: [
        const DropdownMenuItem(value: 'all', child: Text('Tất cả luật sư')),
        ..._uniqueLawyers.map((lawyer) => DropdownMenuItem(
              value: lawyer,
              child: Text(lawyer),
            )),
      ],
      onChanged: (value) {
        setState(() {
          _selectedLawyer = value ?? 'all';
          _applyFilters();
        });
      },
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Card(
      color: AppColors.surface,
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
                // Avatar
                CircleAvatar(
                  radius: isMobile ? 18 : 20,
                  backgroundImage: (_avatarByAppointmentId[appointment.id] ?? '').isNotEmpty
                      ? NetworkImage(_avatarByAppointmentId[appointment.id]!)
                      : null,
                  child: (_avatarByAppointmentId[appointment.id] ?? '').isEmpty
                      ? const Icon(Icons.person, color: AppColors.onSurfaceVariant)
                      : null,
                  backgroundColor: AppColors.surfaceVariant,
                ),
                const SizedBox(width: 12),
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
                        appointment.lawyerName,
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if ((_emailByAppointmentId[appointment.id] ?? '').isNotEmpty)
                            _infoPill(icon: Icons.email, text: _emailByAppointmentId[appointment.id]!),
                          if ((_phoneByAppointmentId[appointment.id] ?? '').isNotEmpty)
                            _infoPill(icon: Icons.phone, text: _phoneByAppointmentId[appointment.id]!),
                          if ((_specByAppointmentId[appointment.id] ?? '').isNotEmpty)
                            _tagChip(label: _specByAppointmentId[appointment.id]!),
                        ],
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
                  const Icon(Icons.calendar_today, size: 14, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    '${appointment.appointmentDate.day}/${appointment.appointmentDate.month}/${appointment.appointmentDate.year}',
                    style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    appointment.timeSlot,
                    style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.event_available, size: 14, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    'Tạo: ${appointment.createdAt.day}/${appointment.createdAt.month}/${appointment.createdAt.year}',
                    style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
            ] else ...[
              // Desktop layout - inline
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    '${appointment.appointmentDate.day}/${appointment.appointmentDate.month}/${appointment.appointmentDate.year}',
                    style: const TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, size: 16, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    appointment.timeSlot,
                    style: const TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.event_available, size: 16, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    'Tạo: ${appointment.createdAt.day}/${appointment.createdAt.month}/${appointment.createdAt.year}',
                    style: const TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.description,
                    size: isMobile ? 14 : 16, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    appointment.description,
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: isMobile ? 13 : 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Services chips
            if ((_servicesByAppointmentId[appointment.id] ?? '').isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: (_servicesByAppointmentId[appointment.id]!
                        .split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty))
                    .map((s) => _tagChip(label: s))
                    .toList(),
              ),
              const SizedBox(height: 8),
            ],

            Row(
              children: [
                Icon(Icons.attach_money,
                    size: isMobile ? 14 : 16, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  '${appointment.fee.toStringAsFixed(0)} VNĐ',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
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
                      size: isMobile ? 14 : 16, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment.notes,
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: isMobile ? 13 : 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: isMobile ? 12 : 16),

            // Actions
            if (isMobile) ...[
              // Mobile layout - stacked buttons
              if (appointment.status == AppointmentStatus.pending) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _updateAppointmentStatus(
                        appointment, AppointmentStatus.confirmed),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Xác nhận'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.info,
                      foregroundColor: AppColors.onInfo,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
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
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.onSuccess,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
              if (appointment.status != AppointmentStatus.completed &&
                  appointment.status != AppointmentStatus.cancelled) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _updateAppointmentStatus(
                        appointment, AppointmentStatus.cancelled),
                    icon: const Icon(Icons.cancel, size: 16),
                    label: const Text('Hủy'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.onError,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showDeleteDialog(appointment),
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  label: const Text('Xóa', style: TextStyle(color: AppColors.error)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ] else ...[
              // Desktop layout - inline buttons
              Row(
                children: [
                  if (appointment.status == AppointmentStatus.pending) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateAppointmentStatus(
                            appointment, AppointmentStatus.confirmed),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Xác nhận'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.info,
                          foregroundColor: AppColors.onInfo,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (appointment.status == AppointmentStatus.confirmed) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateAppointmentStatus(
                            appointment, AppointmentStatus.completed),
                        icon: const Icon(Icons.done, size: 16),
                        label: const Text('Hoàn thành'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: AppColors.onSuccess,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (appointment.status != AppointmentStatus.completed &&
                      appointment.status != AppointmentStatus.cancelled) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateAppointmentStatus(
                            appointment, AppointmentStatus.cancelled),
                        icon: const Icon(Icons.cancel, size: 16),
                        label: const Text('Hủy'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: AppColors.onError,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  IconButton(
                    onPressed: () => _showDeleteDialog(appointment),
                    icon: const Icon(Icons.delete, color: AppColors.error),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoPill({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _tagChip({required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
