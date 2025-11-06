import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/appointment.dart';

class AppointmentTable extends StatelessWidget {
  final List<Appointment> appointments;
  final VoidCallback? onBookAppointment;

  const AppointmentTable({
    super.key,
    required this.appointments,
    this.onBookAppointment,
  });

  @override
  Widget build(BuildContext context) {
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
          if (isTablet) _buildTableHeader(context),
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
                    : _buildMobileAppointmentList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
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
            child: _buildHeaderCell(context, 'LUẬT SƯ'),
          ),
          Expanded(
            flex: 2,
            child: _buildHeaderCell(context, 'NGÀY'),
          ),
          Expanded(
            flex: 2,
            child: _buildHeaderCell(context, 'DỊCH VỤ'),
          ),
          Expanded(
            flex: 1,
            child: _buildHeaderCell(context, 'TRẠNG THÁI'),
          ),
          Expanded(
            flex: 1,
            child: _buildHeaderCell(context, 'THAO TÁC'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(BuildContext context, String text) {
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
            child: _buildDataCell(
              appointment.services.isNotEmpty
                  ? appointment.services.join(', ')
                  : appointment.service,
            ),
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

  Widget _buildMobileAppointmentList() {
    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        return _buildMobileAppointmentCard(context, appointments[index], index);
      },
    );
  }

  Widget _buildMobileAppointmentCard(
      BuildContext context, Appointment appointment, int index) {
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
                    color: AppColors.onSurface,
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
          // Display all services
          if (appointment.services.isNotEmpty) ...[
            Text(
              'Dịch vụ:',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: screenHeight * 0.005),
            // Show all services as chips or comma-separated
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: appointment.services.map((service) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200, width: 1),
                  ),
                  child: Text(
                    service,
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: Colors.green.shade800,
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            Text(
              'Dịch vụ: ${appointment.service}',
              style: TextStyle(
                fontSize: screenWidth * 0.035, // 3.5% of screen width
                color: Colors.grey[600],
              ),
            ),
          ],
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có lịch hẹn nào',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy đặt lịch với luật sư để bắt đầu',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onBookAppointment,
              icon: const Icon(Icons.add),
              label: const Text('Đặt lịch ngay'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
