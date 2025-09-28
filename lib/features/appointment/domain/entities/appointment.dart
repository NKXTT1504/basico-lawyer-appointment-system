class Appointment {
  final String id;
  final String lawyerName;
  final String date;
  final String time;
  final String dayOfWeek;
  final String service;
  final AppointmentStatus status;
  final String? action;

  const Appointment({
    required this.id,
    required this.lawyerName,
    required this.date,
    required this.time,
    required this.dayOfWeek,
    required this.service,
    required this.status,
    this.action,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
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
}

enum AppointmentStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}

extension AppointmentStatusExtension on AppointmentStatus {
  String get displayName {
    switch (this) {
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

  String get colorCode {
    switch (this) {
      case AppointmentStatus.pending:
        return '#FFA726'; // Orange
      case AppointmentStatus.confirmed:
        return '#2196F3'; // Blue
      case AppointmentStatus.completed:
        return '#4CAF50'; // Green
      case AppointmentStatus.cancelled:
        return '#F44336'; // Red
    }
  }
}
