import '../../features/appointment/domain/entities/appointment.dart'
    as home_appointment;
import '../../features/admin/data/models/appointment.dart' as admin_appointment;
import '../../features/admin/data/services/user_storage_service.dart';
import '../../features/admin/data/models/admin_user.dart' as admin_model;

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
    final startTime = timeParts.isNotEmpty ? timeParts[0] : '';

    return admin_appointment.Appointment(
      id: homeAppointment.id,
      customerId: 'customer_${homeAppointment.id}', // Generate customer ID
      customerName:
          'Khách hàng ${homeAppointment.id}', // Generate customer name
      lawyerId: 'lawyer_${homeAppointment.id}', // Generate lawyer ID
      lawyerName: homeAppointment.lawyerName,
      appointmentDate: appointmentDate,
      timeSlot: timeParts.length == 2 && startTime.isNotEmpty
          ? '$startTime - ${timeParts[1]}'
          : homeAppointment.time,
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
    final adminList = await UserStorageService.getAppointments();
    return adminList.map(convertToHomeFormat).toList();
  }

  /// Get appointments for the current logged-in customer only
  static Future<List<home_appointment.Appointment>>
      getHomeAppointmentsForCurrentCustomer() async {
    final user = await UserStorageService.getCurrentUser();
    if (user == null || user.role != admin_model.UserRole.customer) {
      return <home_appointment.Appointment>[];
    }
    final customer = await UserStorageService.getCurrentCustomerProfile();
    if (customer == null) return <home_appointment.Appointment>[];
    final adminList = await UserStorageService.getAppointments();
    final mine = adminList.where((a) => a.customerId == customer.id).toList();
    return mine.map(convertToHomeFormat).toList();
  }

  /// Get all appointments in admin format
  static Future<List<admin_appointment.Appointment>>
      getAdminAppointments() async {
    return await UserStorageService.getAppointments();
  }

  /// Create a new admin-format appointment and persist
  static Future<void> addAdminAppointment(
      admin_appointment.Appointment appointment) async {
    await UserStorageService.addAppointment(appointment);
  }

  /// Create from home-format (customer side) and persist in admin storage
  static Future<void> addFromHomeAppointment(
      home_appointment.Appointment homeAppointment) async {
    final admin = convertToAdminFormat(homeAppointment);
    await UserStorageService.addAppointment(admin);
  }

  /// Create a new booking for the current customer with a given lawyer
  static Future<bool> createBookingForLawyer({
    required String lawyerId,
    required String lawyerName,
    required String service,
    DateTime? date,
    String timeSlot = '14:00 - 15:00',
  }) async {
    final user = await UserStorageService.getCurrentUser();
    if (user == null || user.role != admin_model.UserRole.customer)
      return false;
    final customer = await UserStorageService.getCurrentCustomerProfile();
    if (customer == null) return false;

    final now = DateTime.now();
    final chosenDate = date ?? now.add(const Duration(days: 1));

    // Conflict check: prevent overlapping bookings for the same lawyer at the same day/time
    final existing = await UserStorageService.getAppointments();
    final hasConflict = existing.any((a) =>
        a.lawyerId == lawyerId &&
        a.appointmentDate.year == chosenDate.year &&
        a.appointmentDate.month == chosenDate.month &&
        a.appointmentDate.day == chosenDate.day &&
        a.timeSlot == timeSlot &&
        a.status != admin_appointment.AppointmentStatus.cancelled);
    if (hasConflict) return false;
    final newApt = admin_appointment.Appointment(
      id: 'apt_${DateTime.now().millisecondsSinceEpoch}',
      customerId: customer.id,
      customerName: customer.name,
      lawyerId: lawyerId,
      lawyerName: lawyerName,
      appointmentDate:
          DateTime(chosenDate.year, chosenDate.month, chosenDate.day, 0, 0),
      timeSlot: timeSlot,
      duration: '1 giờ',
      type: service,
      description: 'Đặt lịch qua ứng dụng',
      status: admin_appointment.AppointmentStatus.pending,
      notes: '',
      fee: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await UserStorageService.addAppointment(newApt);
    return true;
  }

  /// Return occupied time slots for a lawyer on a specific day (not cancelled)
  static Future<Set<String>> getOccupiedTimeSlots({
    required String lawyerId,
    required DateTime date,
  }) async {
    final list = await UserStorageService.getAppointments();
    final dayMatches = list.where((a) =>
        a.lawyerId == lawyerId &&
        a.appointmentDate.year == date.year &&
        a.appointmentDate.month == date.month &&
        a.appointmentDate.day == date.day &&
        a.status != admin_appointment.AppointmentStatus.cancelled);
    return dayMatches.map((a) => a.timeSlot).toSet();
  }

  /// Update appointment status by id
  static Future<void> updateAdminAppointmentStatus(
      {required String id,
      required admin_appointment.AppointmentStatus status,
      String? notes}) async {
    final list = await UserStorageService.getAppointments();
    final index = list.indexWhere((a) => a.id == id);
    if (index == -1) return;
    final existing = list[index];
    final updated = admin_appointment.Appointment(
      id: existing.id,
      customerId: existing.customerId,
      customerName: existing.customerName,
      lawyerId: existing.lawyerId,
      lawyerName: existing.lawyerName,
      appointmentDate: existing.appointmentDate,
      timeSlot: existing.timeSlot,
      duration: existing.duration,
      type: existing.type,
      description: existing.description,
      status: status,
      notes: notes ?? existing.notes,
      fee: existing.fee,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    await UserStorageService.updateAppointment(updated);
  }
}
