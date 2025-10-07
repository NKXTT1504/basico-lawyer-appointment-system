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
              status: appointment.status,
              action: appointment.action,
            ))
        .toList();
  }

  List<AppointmentModel> _getMockAppointments() {
    return [
      const AppointmentModel(
        id: '1',
        lawyerName: 'Nguyễn Văn A',
        date: '28/07/2025',
        time: '08:00 ~ 10:00',
        dayOfWeek: 'Thứ Hai',
        service: 'Luật Doanh Nghiệp',
        status: AppointmentStatus.cancelled,
        action: '-',
      ),
      const AppointmentModel(
        id: '2',
        lawyerName: 'Nguyễn Văn A',
        date: '28/07/2025',
        time: '10:00 ~ 12:00',
        dayOfWeek: 'Thứ Hai',
        service: 'Luật Doanh Nghiệp',
        status: AppointmentStatus.completed,
        action: '-',
      ),
      const AppointmentModel(
        id: '3',
        lawyerName: 'Nguyễn Văn A',
        date: '28/07/2025',
        time: '08:00 ~ 10:00',
        dayOfWeek: 'Thứ Hai',
        service: 'Luật Doanh Nghiệp',
        status: AppointmentStatus.completed,
        action: '-',
      ),
      const AppointmentModel(
        id: '4',
        lawyerName: 'Nguyễn Văn D',
        date: '25/07/2025',
        time: '08:00 ~ 10:00',
        dayOfWeek: 'Thứ Sáu',
        service: 'Luật Doanh Nghiệp',
        status: AppointmentStatus.completed,
        action: '-',
      ),
      const AppointmentModel(
        id: '5',
        lawyerName: 'Trần Thị An',
        date: '30/07/2025',
        time: '13:00 ~ 15:00',
        dayOfWeek: 'Thứ Tư',
        service: 'Luật Doanh Nghiệp',
        status: AppointmentStatus.completed,
        action: '-',
      ),
      const AppointmentModel(
        id: '6',
        lawyerName: 'Lê Văn B',
        date: '15/08/2025',
        time: '09:00 ~ 11:00',
        dayOfWeek: 'Thứ Năm',
        service: 'Luật Hôn Nhân Gia Đình',
        status: AppointmentStatus.confirmed,
        action: 'Hủy',
      ),
      const AppointmentModel(
        id: '7',
        lawyerName: 'Phạm Thị C',
        date: '20/08/2025',
        time: '14:00 ~ 16:00',
        dayOfWeek: 'Thứ Ba',
        service: 'Luật Lao Động',
        status: AppointmentStatus.confirmed,
        action: 'Hủy',
      ),
    ];
  }
}
