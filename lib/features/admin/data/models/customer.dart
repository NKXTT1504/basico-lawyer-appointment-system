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
    return Customer(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String,
      occupation: json['occupation'] as String,
      notes: json['notes'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
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

