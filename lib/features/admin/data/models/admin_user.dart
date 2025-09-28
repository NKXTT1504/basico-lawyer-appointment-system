import 'package:equatable/equatable.dart';

enum UserRole {
  customer,
  admin,
  lawyer,
}

class User extends Equatable {
  final String id;
  final String email;
  final String password;
  final String name;
  final UserRole role;
  final DateTime createdAt;
  final bool isActive;

  const User({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.role,
    required this.createdAt,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      name: json['name'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.customer,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? password,
    String? name,
    UserRole? role,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props =>
      [id, email, password, name, role, createdAt, isActive];
}
