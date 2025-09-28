import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/appointment.dart';

class AppointmentTable extends StatelessWidget {
  final List<Appointment> appointments;

  const AppointmentTable({
    super.key,
    required this.appointments,
  });

  @override
  Widget build(BuildContext context) {
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
        color: AppColors.onSurface,
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
