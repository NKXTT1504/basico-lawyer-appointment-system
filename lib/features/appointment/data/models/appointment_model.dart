import '../../domain/entities/appointment.dart';

class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.id,
    required super.lawyerName,
    required super.date,
    required super.time,
    required super.dayOfWeek,
    required super.service,
    required super.status,
    super.action,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      lawyerName: json['lawyerName'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      dayOfWeek: json['dayOfWeek'] as String,
      service: json['service'] as String,
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      action: json['action'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lawyerName': lawyerName,
      'date': date,
      'time': time,
      'dayOfWeek': dayOfWeek,
      'service': service,
      'status': status.name,
      'action': action,
    };
  }

  factory AppointmentModel.fromEntity(Appointment appointment) {
    return AppointmentModel(
      id: appointment.id,
      lawyerName: appointment.lawyerName,
      date: appointment.date,
      time: appointment.time,
      dayOfWeek: appointment.dayOfWeek,
      service: appointment.service,
      status: appointment.status,
      action: appointment.action,
    );
  }
}
