import 'package:equatable/equatable.dart';

class Employee extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String position;
  final String department;
  final DateTime hireDate;
  final double salary;
  final String address;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.position,
    required this.department,
    required this.hireDate,
    required this.salary,
    required this.address,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      position: json['position'] as String,
      department: json['department'] as String,
      hireDate: DateTime.parse(json['hireDate'] as String),
      salary: (json['salary'] as num).toDouble(),
      address: json['address'] as String,
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
      'position': position,
      'department': department,
      'hireDate': hireDate.toIso8601String(),
      'salary': salary,
      'address': address,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Employee copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? position,
    String? department,
    DateTime? hireDate,
    double? salary,
    String? address,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      position: position ?? this.position,
      department: department ?? this.department,
      hireDate: hireDate ?? this.hireDate,
      salary: salary ?? this.salary,
      address: address ?? this.address,
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
        position,
        department,
        hireDate,
        salary,
        address,
        isActive,
        createdAt,
        updatedAt
      ];
}

