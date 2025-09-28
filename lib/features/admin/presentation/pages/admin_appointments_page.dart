import 'package:flutter/material.dart';
import '../../data/services/user_storage_service.dart';
import '../../data/models/appointment.dart';

class AdminAppointmentsPage extends StatefulWidget {
  const AdminAppointmentsPage({super.key});

  @override
  State<AdminAppointmentsPage> createState() => _AdminAppointmentsPageState();
}

class _AdminAppointmentsPageState extends State<AdminAppointmentsPage> {
  List<Appointment> _appointments = [];
  bool _isLoading = true;
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final appointments = await UserStorageService.getAppointments();
      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Có lỗi xảy ra: $e');
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
      final updatedAppointment = appointment.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      await UserStorageService.updateAppointment(updatedAppointment);
      await _loadAppointments();
      _showSuccessSnackBar('Cập nhật trạng thái thành công');
    } catch (e) {
      _showErrorSnackBar('Có lỗi xảy ra: $e');
    }
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

  List<Appointment> get _filteredAppointments {
    if (_selectedStatus == 'all') {
      return _appointments;
    }
    return _appointments
        .where((apt) => apt.status.name == _selectedStatus)
        .toList();
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý đặt lịch'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAppointments,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.all(16),
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

          // Appointments list
          Expanded(
            child: _filteredAppointments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Không có đặt lịch nào',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
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
        });
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment.lawyerName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(appointment.status),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Details
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

            const SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.description, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    appointment.description,
                    style: TextStyle(color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '${appointment.fee.toStringAsFixed(0)} VNĐ',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            if (appointment.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment.notes,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Actions
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
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
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
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
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
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                IconButton(
                  onPressed: () => _showDeleteDialog(appointment),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
