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
    return Appointment(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      lawyerId: json['lawyerId'] as String,
      lawyerName: json['lawyerName'] as String,
      appointmentDate: DateTime.parse(json['appointmentDate'] as String),
      timeSlot: json['timeSlot'] as String,
      duration: json['duration'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      notes: json['notes'] as String? ?? '',
      fee: (json['fee'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
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

