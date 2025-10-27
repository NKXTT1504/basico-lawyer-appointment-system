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
    // Support both old format and new API format
    final String id = json['id']?.toString() ?? '';
    final String lawyerName = json['lawyerName']?.toString() ??
        (json['lawyerProfile'] != null
            ? 'Luật sư #${json['lawyerId']?.toString() ?? ''}'
            : '');

    // Parse date from scheduledAt
    DateTime? scheduledDate;
    if (json['scheduledAt'] != null) {
      try {
        scheduledDate = DateTime.parse(json['scheduledAt'].toString());
      } catch (e) {
        scheduledDate = DateTime.now();
      }
    } else {
      scheduledDate = DateTime.parse(
          json['date']?.toString() ?? DateTime.now().toIso8601String());
    }

    final String date =
        '${scheduledDate.day}/${scheduledDate.month}/${scheduledDate.year}';

    final String time =
        json['time']?.toString() ?? json['slot']?.toString() ?? '';

    // Get day of week
    final days = [
      'Chủ nhật',
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy'
    ];
    final String dayOfWeek = days[scheduledDate.weekday % 7];

    // Get service
    String service = json['service']?.toString() ??
        (json['services'] != null && (json['services'] as List).isNotEmpty
            ? (json['services'] as List).first.toString()
            : json['spec']?.toString() ?? '');

    // Parse status
    AppointmentStatus status;
    if (json['status'] is int) {
      switch (json['status'] as int) {
        case 0:
          status = AppointmentStatus.pending;
          break;
        case 1:
          status = AppointmentStatus.confirmed;
          break;
        case 2:
          status = AppointmentStatus.completed;
          break;
        case 3:
          status = AppointmentStatus.cancelled;
          break;
        default:
          status = AppointmentStatus.pending;
      }
    } else {
      status = AppointmentStatus.values.firstWhere(
        (e) => e.name == json['status']?.toString(),
        orElse: () => AppointmentStatus.pending,
      );
    }

    return Appointment(
      id: id,
      lawyerName: lawyerName,
      date: date,
      time: time,
      dayOfWeek: dayOfWeek,
      service: service,
      status: status,
      action: json['action']?.toString(),
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
