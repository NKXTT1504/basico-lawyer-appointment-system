import '../../features/appointment/domain/entities/appointment.dart'
    as home_appointment;
import '../../features/admin/data/models/appointment.dart' as admin_appointment;

class AppointmentSyncService {
  /// Convert from home appointment format to admin appointment format
  static admin_appointment.Appointment convertToAdminFormat(
      home_appointment.Appointment homeAppointment) {
    // Parse date from string format (e.g., "28/07/2025")
    final dateParts = homeAppointment.date.split('/');
    final day = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final year = int.parse(dateParts[2]);
    final appointmentDate = DateTime(year, month, day);

    // Parse time from string format (e.g., "08:00 ~ 10:00")
    final timeParts = homeAppointment.time.split(' ~ ');
    final startTime = timeParts[0];
    final endTime = timeParts.length > 1 ? timeParts[1] : startTime;

    return admin_appointment.Appointment(
      id: homeAppointment.id,
      customerId: 'customer_${homeAppointment.id}', // Generate customer ID
      customerName:
          'Khách hàng ${homeAppointment.id}', // Generate customer name
      lawyerId: 'lawyer_${homeAppointment.id}', // Generate lawyer ID
      lawyerName: homeAppointment.lawyerName,
      appointmentDate: appointmentDate,
      timeSlot: homeAppointment.time,
      duration: '2 giờ', // Default duration
      type: homeAppointment.service,
      description: 'Dịch vụ ${homeAppointment.service}',
      status: _convertStatus(homeAppointment.status),
      notes: homeAppointment.action ?? '',
      fee: 500000.0, // Default fee
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Convert from admin appointment format to home appointment format
  static home_appointment.Appointment convertToHomeFormat(
      admin_appointment.Appointment adminAppointment) {
    // Format date as DD/MM/YYYY
    final date =
        '${adminAppointment.appointmentDate.day.toString().padLeft(2, '0')}/'
        '${adminAppointment.appointmentDate.month.toString().padLeft(2, '0')}/'
        '${adminAppointment.appointmentDate.year}';

    // Get day of week
    final weekdays = [
      'Chủ Nhật',
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy'
    ];
    final dayOfWeek = weekdays[adminAppointment.appointmentDate.weekday % 7];

    return home_appointment.Appointment(
      id: adminAppointment.id,
      lawyerName: adminAppointment.lawyerName,
      date: date,
      time: adminAppointment.timeSlot,
      dayOfWeek: dayOfWeek,
      service: adminAppointment.type,
      status: _convertStatusToHome(adminAppointment.status),
      action: adminAppointment.notes.isNotEmpty ? adminAppointment.notes : null,
    );
  }

  /// Convert status from home format to admin format
  static admin_appointment.AppointmentStatus _convertStatus(
      home_appointment.AppointmentStatus homeStatus) {
    switch (homeStatus) {
      case home_appointment.AppointmentStatus.pending:
        return admin_appointment.AppointmentStatus.pending;
      case home_appointment.AppointmentStatus.confirmed:
        return admin_appointment.AppointmentStatus.confirmed;
      case home_appointment.AppointmentStatus.completed:
        return admin_appointment.AppointmentStatus.completed;
      case home_appointment.AppointmentStatus.cancelled:
        return admin_appointment.AppointmentStatus.cancelled;
    }
  }

  /// Convert status from admin format to home format
  static home_appointment.AppointmentStatus _convertStatusToHome(
      admin_appointment.AppointmentStatus adminStatus) {
    switch (adminStatus) {
      case admin_appointment.AppointmentStatus.pending:
        return home_appointment.AppointmentStatus.pending;
      case admin_appointment.AppointmentStatus.confirmed:
        return home_appointment.AppointmentStatus.confirmed;
      case admin_appointment.AppointmentStatus.completed:
        return home_appointment.AppointmentStatus.completed;
      case admin_appointment.AppointmentStatus.cancelled:
        return home_appointment.AppointmentStatus.cancelled;
    }
  }

  /// Get all appointments in home format
  static Future<List<home_appointment.Appointment>>
      getHomeAppointments() async {
    // This would typically fetch from a shared data source
    // For now, we'll return mock data that matches the home format
    return [
      const home_appointment.Appointment(
        id: '1',
        lawyerName: 'Nguyễn Văn A',
        date: '28/07/2025',
        time: '08:00 ~ 10:00',
        dayOfWeek: 'Thứ Hai',
        service: 'Luật Doanh Nghiệp',
        status: home_appointment.AppointmentStatus.cancelled,
        action: '-',
      ),
      const home_appointment.Appointment(
        id: '2',
        lawyerName: 'Nguyễn Văn A',
        date: '28/07/2025',
        time: '10:00 ~ 12:00',
        dayOfWeek: 'Thứ Hai',
        service: 'Luật Doanh Nghiệp',
        status: home_appointment.AppointmentStatus.completed,
        action: '-',
      ),
      const home_appointment.Appointment(
        id: '3',
        lawyerName: 'Nguyễn Văn A',
        date: '28/07/2025',
        time: '08:00 ~ 10:00',
        dayOfWeek: 'Thứ Hai',
        service: 'Luật Doanh Nghiệp',
        status: home_appointment.AppointmentStatus.completed,
        action: '-',
      ),
      const home_appointment.Appointment(
        id: '4',
        lawyerName: 'Nguyễn Văn D',
        date: '25/07/2025',
        time: '08:00 ~ 10:00',
        dayOfWeek: 'Thứ Sáu',
        service: 'Luật Doanh Nghiệp',
        status: home_appointment.AppointmentStatus.completed,
        action: '-',
      ),
      const home_appointment.Appointment(
        id: '5',
        lawyerName: 'Trần Thị An',
        date: '30/07/2025',
        time: '13:00 ~ 15:00',
        dayOfWeek: 'Thứ Tư',
        service: 'Luật Doanh Nghiệp',
        status: home_appointment.AppointmentStatus.completed,
        action: '-',
      ),
      const home_appointment.Appointment(
        id: '6',
        lawyerName: 'Lê Văn B',
        date: '15/08/2025',
        time: '09:00 ~ 11:00',
        dayOfWeek: 'Thứ Năm',
        service: 'Luật Hôn Nhân Gia Đình',
        status: home_appointment.AppointmentStatus.confirmed,
        action: 'Hủy',
      ),
      const home_appointment.Appointment(
        id: '7',
        lawyerName: 'Phạm Thị C',
        date: '20/08/2025',
        time: '14:00 ~ 16:00',
        dayOfWeek: 'Thứ Ba',
        service: 'Luật Lao Động',
        status: home_appointment.AppointmentStatus.confirmed,
        action: 'Hủy',
      ),
    ];
  }

  /// Get all appointments in admin format
  static Future<List<admin_appointment.Appointment>>
      getAdminAppointments() async {
    // This would typically fetch from a shared data source
    // For now, we'll return mock data that matches the admin format
    return [
      admin_appointment.Appointment(
        id: '1',
        customerId: 'customer_1',
        customerName: 'Nguyễn Thị A',
        lawyerId: 'lawyer_1',
        lawyerName: 'Nguyễn Văn A',
        appointmentDate: DateTime(2025, 7, 28),
        timeSlot: '08:00 - 10:00',
        duration: '2 giờ',
        type: 'Luật Doanh Nghiệp',
        description: 'Tư vấn về hợp đồng lao động',
        status: admin_appointment.AppointmentStatus.cancelled,
        notes: 'Khách hàng hủy lịch',
        fee: 500000.0,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      admin_appointment.Appointment(
        id: '2',
        customerId: 'customer_2',
        customerName: 'Trần Văn B',
        lawyerId: 'lawyer_1',
        lawyerName: 'Nguyễn Văn A',
        appointmentDate: DateTime(2025, 7, 28),
        timeSlot: '10:00 - 12:00',
        duration: '2 giờ',
        type: 'Luật Doanh Nghiệp',
        description: 'Tư vấn về thành lập công ty',
        status: admin_appointment.AppointmentStatus.completed,
        notes: 'Hoàn thành tốt',
        fee: 800000.0,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      admin_appointment.Appointment(
        id: '3',
        customerId: 'customer_3',
        customerName: 'Lê Thị C',
        lawyerId: 'lawyer_2',
        lawyerName: 'Trần Thị An',
        appointmentDate: DateTime(2025, 7, 30),
        timeSlot: '13:00 - 15:00',
        duration: '2 giờ',
        type: 'Luật Hôn Nhân Gia Đình',
        description: 'Tư vấn về ly hôn',
        status: admin_appointment.AppointmentStatus.confirmed,
        notes: '',
        fee: 600000.0,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }
}
