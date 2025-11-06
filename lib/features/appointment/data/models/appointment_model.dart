import '../models/appointment.dart';

class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.id,
    required super.lawyerName,
    required super.date,
    required super.time,
    required super.dayOfWeek,
    required super.service,
    required super.services,
    required super.status,
    super.action,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    // Parse services
    List<String> servicesList = [];
    if (json['services'] != null) {
      if (json['services'] is List) {
        servicesList =
            (json['services'] as List).map((s) => s.toString()).toList();
      } else if (json['services'] is String) {
        servicesList = (json['services'] as String)
            .split(',')
            .map((s) => s.trim())
            .toList();
      }
    }
    if (servicesList.isEmpty && json['service'] != null) {
      servicesList = [json['service'] as String];
    }

    return AppointmentModel(
      id: json['id'] as String,
      lawyerName: json['lawyerName'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      dayOfWeek: json['dayOfWeek'] as String,
      service: servicesList.isNotEmpty
          ? servicesList.first
          : (json['service'] as String? ?? ''),
      services: servicesList,
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
      services: appointment.services,
      status: appointment.status,
      action: appointment.action,
    );
  }
}
