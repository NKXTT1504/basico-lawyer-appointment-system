import 'dart:convert';
import '../../../../core/utils/slot_mapper.dart';

class Appointment {
  final String id;
  final String lawyerName;
  final String date;
  final String time;
  final String dayOfWeek;
  final String service; // For backward compatibility - first service or spec
  final List<String> services; // All services
  final AppointmentStatus status;
  final String? action;

  const Appointment({
    required this.id,
    required this.lawyerName,
    required this.date,
    required this.time,
    required this.dayOfWeek,
    required this.service,
    required this.services,
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

    // Map slot number from backend to time range for display
    final slotFromBackend =
        json['time']?.toString() ?? json['slot']?.toString() ?? '';
    final String time = SlotMapper.slotToTime(slotFromBackend);

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

    // Parse services - can be a List, JSON string, or comma-separated string
    List<String> servicesList = [];
    if (json['services'] != null) {
      if (json['services'] is List) {
        servicesList = (json['services'] as List)
            .map((s) => s.toString())
            .where((s) => s.isNotEmpty)
            .toList();
      } else if (json['services'] is String) {
        // Try to parse as JSON string first
        try {
          final str = json['services'] as String;
          if (str.trim().startsWith('[')) {
            // It's a JSON array string, decode it
            final decoded = jsonDecode(str) as List;
            servicesList = decoded
                .map((s) => s.toString())
                .where((s) => s.isNotEmpty)
                .toList();
          } else {
            // It's a comma-separated string
            servicesList = str
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
          }
        } catch (e) {
          // If JSON parsing fails, try as comma-separated
          final str = json['services'].toString();
          servicesList = str
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        }
      }
    }

    // Fallback to spec if services is empty
    if (servicesList.isEmpty && json['spec'] != null) {
      final spec = json['spec'].toString();
      servicesList = spec
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    // If still empty, try the 'service' field
    if (servicesList.isEmpty && json['service'] != null) {
      servicesList = [json['service'].toString()];
    }

    // Get first service for backward compatibility
    String service = servicesList.isNotEmpty ? servicesList.first : '';

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
      services: servicesList,
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
