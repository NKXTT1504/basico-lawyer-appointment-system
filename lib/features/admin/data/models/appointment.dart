import 'package:equatable/equatable.dart';

enum AppointmentStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}

class Appointment extends Equatable {
  final String id;
  final String customerId;
  final String customerName;
  final String lawyerId;
  final String lawyerName;
  final DateTime appointmentDate;
  final String timeSlot;
  final String duration;
  final String type;
  final String description;
  final AppointmentStatus status;
  final String notes;
  final double fee;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Appointment({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.lawyerId,
    required this.lawyerName,
    required this.appointmentDate,
    required this.timeSlot,
    required this.duration,
    required this.type,
    required this.description,
    required this.status,
    this.notes = '',
    required this.fee,
    required this.createdAt,
    this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    // Safe parsing for API response
    String parseId(dynamic value) => (value ?? '').toString();
    String parseString(dynamic value, {String fallback = ''}) =>
        (value ?? fallback).toString();
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    // Parse status from int (0=pending, 1=confirmed, 2=completed, 3=cancelled)
    AppointmentStatus parseStatus(dynamic value) {
      if (value is int) {
        switch (value) {
          case 0:
            return AppointmentStatus.pending;
          case 1:
            return AppointmentStatus.confirmed;
          case 2:
            return AppointmentStatus.completed;
          case 3:
            return AppointmentStatus.cancelled;
          default:
            return AppointmentStatus.pending;
        }
      }
      return AppointmentStatus.values.firstWhere(
        (e) => e.name == value?.toString(),
        orElse: () => AppointmentStatus.pending,
      );
    }

    // Extract customer name from nested user object
    String customerName = '';
    if (json['user'] is Map<String, dynamic>) {
      customerName =
          parseString(json['user']['fullName'] ?? json['user']['name']);
    }

    // Extract lawyer name from nested lawyerProfile object
    String lawyerName = '';
    if (json['lawyerProfile'] is Map<String, dynamic>) {
      lawyerName = 'Luật sư #${parseId(json['lawyerId'])}';
    } else {
      lawyerName = 'Luật sư #${parseId(json['lawyerId'])}';
    }

    // Extract service description
    String description = '';
    if (json['services'] is List && (json['services'] as List).isNotEmpty) {
      description = parseString((json['services'] as List).first);
    } else {
      description = parseString(json['spec']);
    }

    return Appointment(
      id: parseId(json['id']),
      customerId: parseId(json['userId']),
      customerName: customerName,
      lawyerId: parseId(json['lawyerId']),
      lawyerName: lawyerName,
      appointmentDate: parseDate(json['scheduledAt']),
      timeSlot: parseString(json['slot']),
      duration: '60m', // Default duration
      type: parseString(json['spec']),
      description: description,
      status: parseStatus(json['status']),
      notes: parseString(json['note']),
      fee: (json['lawyerProfile']?['pricePerHour'] as num?)?.toDouble() ?? 0.0,
      createdAt: parseDate(json['createAt']),
      updatedAt:
          json['updatedAt'] != null ? parseDate(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'lawyerId': lawyerId,
      'lawyerName': lawyerName,
      'appointmentDate': appointmentDate.toIso8601String(),
      'timeSlot': timeSlot,
      'duration': duration,
      'type': type,
      'description': description,
      'status': status.name,
      'notes': notes,
      'fee': fee,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Appointment copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? lawyerId,
    String? lawyerName,
    DateTime? appointmentDate,
    String? timeSlot,
    String? duration,
    String? type,
    String? description,
    AppointmentStatus? status,
    String? notes,
    double? fee,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      lawyerId: lawyerId ?? this.lawyerId,
      lawyerName: lawyerName ?? this.lawyerName,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      timeSlot: timeSlot ?? this.timeSlot,
      duration: duration ?? this.duration,
      type: type ?? this.type,
      description: description ?? this.description,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      fee: fee ?? this.fee,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerName,
        lawyerId,
        lawyerName,
        appointmentDate,
        timeSlot,
        duration,
        type,
        description,
        status,
        notes,
        fee,
        createdAt,
        updatedAt
      ];
}
