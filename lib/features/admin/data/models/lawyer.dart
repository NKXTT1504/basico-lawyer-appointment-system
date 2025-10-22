import 'package:equatable/equatable.dart';

class Lawyer extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String specialization;
  final String licenseNumber;
  final int experienceYears;
  final double hourlyRate;
  final double baseSalary; // lương cứng hàng tháng
  final double commissionRate; // % hoa hồng trên phí khi hoàn thành
  final double successRate; // tỉ lệ thành công 0..1
  final int ongoingCases; // số vụ đang xử lý
  final String bio;
  final String imageUrl;
  final List<String> languages;
  final List<String> certifications;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Lawyer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.specialization,
    required this.licenseNumber,
    required this.experienceYears,
    required this.hourlyRate,
    this.baseSalary = 0,
    this.commissionRate = 0.1,
    this.successRate = 0.7,
    this.ongoingCases = 0,
    this.bio = '',
    this.imageUrl = '',
    this.languages = const [],
    this.certifications = const [],
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory Lawyer.fromJson(Map<String, dynamic> json) {
    return Lawyer(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      specialization: json['specialization'] as String,
      licenseNumber: json['licenseNumber'] as String,
      experienceYears: json['experienceYears'] as int,
      hourlyRate: (json['hourlyRate'] as num).toDouble(),
      baseSalary: (json['baseSalary'] as num?)?.toDouble() ?? 0,
      commissionRate: (json['commissionRate'] as num?)?.toDouble() ?? 0.1,
      successRate: (json['successRate'] as num?)?.toDouble() ?? 0.7,
      ongoingCases: json['ongoingCases'] as int? ?? 0,
      bio: json['bio'] as String? ?? '',
      imageUrl: (json['imageUrl'] as String?) ?? (json['img'] as String?) ?? '',
      languages: List<String>.from(json['languages'] as List? ?? []),
      certifications: List<String>.from(json['certifications'] as List? ?? []),
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
      'specialization': specialization,
      'licenseNumber': licenseNumber,
      'experienceYears': experienceYears,
      'hourlyRate': hourlyRate,
      'baseSalary': baseSalary,
      'commissionRate': commissionRate,
      'successRate': successRate,
      'ongoingCases': ongoingCases,
      'bio': bio,
      'imageUrl': imageUrl,
      'languages': languages,
      'certifications': certifications,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Lawyer copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? specialization,
    String? licenseNumber,
    int? experienceYears,
    double? hourlyRate,
    double? baseSalary,
    double? commissionRate,
    double? successRate,
    int? ongoingCases,
    String? bio,
    String? imageUrl,
    List<String>? languages,
    List<String>? certifications,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Lawyer(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      specialization: specialization ?? this.specialization,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      experienceYears: experienceYears ?? this.experienceYears,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      baseSalary: baseSalary ?? this.baseSalary,
      commissionRate: commissionRate ?? this.commissionRate,
      successRate: successRate ?? this.successRate,
      ongoingCases: ongoingCases ?? this.ongoingCases,
      bio: bio ?? this.bio,
      imageUrl: imageUrl ?? this.imageUrl,
      languages: languages ?? this.languages,
      certifications: certifications ?? this.certifications,
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
        specialization,
        licenseNumber,
        experienceYears,
        hourlyRate,
        baseSalary,
        commissionRate,
        successRate,
        ongoingCases,
        bio,
        imageUrl,
        languages,
        certifications,
        isActive,
        createdAt,
        updatedAt
      ];
}
