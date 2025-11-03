import '../models/appointment_model.dart';
import '../../domain/entities/appointment.dart';
import '../../../../core/services/appointment_sync_service.dart';

abstract class AppointmentLocalDataSource {
  Future<List<AppointmentModel>> getAppointments();
  Future<List<AppointmentModel>> getUpcomingAppointments();
  Future<List<AppointmentModel>> getAppointmentHistory();
}

class AppointmentLocalDataSourceImpl implements AppointmentLocalDataSource {
  @override
  Future<List<AppointmentModel>> getAppointments() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Get appointments from sync service
    final homeAppointments = await AppointmentSyncService.getHomeAppointments();
    return homeAppointments
        .map((appointment) => AppointmentModel(
              id: appointment.id,
              lawyerName: appointment.lawyerName,
              date: appointment.date,
              time: appointment.time,
              dayOfWeek: appointment.dayOfWeek,
              service: appointment.service,
              services: appointment.services,
              status: appointment.status,
              action: appointment.action,
            ))
        .toList();
  }

  @override
  Future<List<AppointmentModel>> getUpcomingAppointments() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final homeAppointments = await AppointmentSyncService.getHomeAppointments();
    return homeAppointments
        .where(
            (appointment) => appointment.status == AppointmentStatus.confirmed)
        .map((appointment) => AppointmentModel(
              id: appointment.id,
              lawyerName: appointment.lawyerName,
              date: appointment.date,
              time: appointment.time,
              dayOfWeek: appointment.dayOfWeek,
              service: appointment.service,
              services: appointment.services,
              status: appointment.status,
              action: appointment.action,
            ))
        .toList();
  }

  @override
  Future<List<AppointmentModel>> getAppointmentHistory() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final homeAppointments = await AppointmentSyncService.getHomeAppointments();
    return homeAppointments
        .where((appointment) =>
            appointment.status == AppointmentStatus.completed ||
            appointment.status == AppointmentStatus.cancelled)
        .map((appointment) => AppointmentModel(
              id: appointment.id,
              lawyerName: appointment.lawyerName,
              date: appointment.date,
              time: appointment.time,
              dayOfWeek: appointment.dayOfWeek,
              service: appointment.service,
              services: appointment.services,
              status: appointment.status,
              action: appointment.action,
            ))
        .toList();
  }
}
