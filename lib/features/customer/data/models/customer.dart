import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final DateTime dateOfBirth;
  final String gender;
  final String occupation;
  final String notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.dateOfBirth,
    required this.gender,
    required this.occupation,
    this.notes = '',
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
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

    return Customer(
      id: parseId(json['id']),
      name: parseString(json['fullName'] ?? json['name'], fallback: 'Unknown'),
      email: parseString(json['email']),
      phone: parseString(json['phoneNumber'] ?? json['phone']),
      address: parseString(json['address']),
      dateOfBirth: parseDate(json['dateOfBirth']),
      gender: parseString(json['gender'], fallback: 'Không xác định'),
      occupation: parseString(json['occupation'], fallback: 'Không xác định'),
      notes: parseString(json['notes']),
      isActive: (json['isActive'] is bool)
          ? (json['isActive'] as bool)
          : (json['isActive']?.toString().toLowerCase() == 'true'),
      createdAt: parseDate(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? parseDate(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'occupation': occupation,
      'notes': notes,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Customer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
    String? occupation,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      occupation: occupation ?? this.occupation,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        address,
        dateOfBirth,
        gender,
        occupation,
        notes,
        isActive,
        createdAt,
        updatedAt
      ];
}

