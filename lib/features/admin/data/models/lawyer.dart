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
    this.languages = const [],
    this.certifications = const [],
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory Lawyer.fromJson(Map<String, dynamic> json) {
    // The backend (Swagger) may use different field names than
    // the existing mobile model. We normalize here to be resilient
    // to both shapes.

    String parseId(dynamic value) {
      if (value == null) return '';
      return value.toString();
    }

    String parseString(dynamic value, {String fallback = ''}) {
      if (value == null) return fallback;
      if (value is String) return value;
      return value.toString();
    }

    int parseInt(dynamic value, {int fallback = 0}) {
      if (value == null) return fallback;
      if (value is int) return value;
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value.toString());
      return parsed ?? fallback;
    }

    double parseDouble(dynamic value, {double fallback = 0}) {
      if (value == null) return fallback;
      if (value is double) return value;
      if (value is num) return value.toDouble();
      final parsed = double.tryParse(value.toString());
      return parsed ?? fallback;
    }

    // specialization may come as a list of practice areas
    String resolveSpecialization(Map<String, dynamic> map) {
      final direct = parseString(map['specialization']);
      if (direct.isNotEmpty) return direct;
      final areas = map['practiceAreas'];
      if (areas is List && areas.isNotEmpty) {
        final names = areas
            .map((e) =>
                (e is Map && e['name'] != null) ? e['name'].toString() : null)
            .whereType<String>()
            .toList();
        if (names.isNotEmpty) {
          return names.join(', ');
        }
      }
      return '';
    }

    DateTime parseDate(dynamic value, {DateTime? fallback}) {
      if (value == null) return fallback ?? DateTime.now();
      if (value is DateTime) return value;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return fallback ?? DateTime.now();
      }
    }

    return Lawyer(
      id: parseId(json['id'] ?? json['lawyerId'] ?? json['userId']),
      name: parseString(json['name'] ?? json['fullName']),
      email: parseString(json['email'] ?? json['userEmail']),
      phone: parseString(json['phone'] ?? json['phoneNumber']),
      address: parseString(json['address']),
      specialization: resolveSpecialization(json),
      licenseNumber: parseString(json['licenseNumber'] ?? json['licenseNum']),
      experienceYears:
          parseInt(json['experienceYears'] ?? json['expYears'], fallback: 0),
      hourlyRate:
          parseDouble(json['hourlyRate'] ?? json['pricePerHour'], fallback: 0),
      baseSalary: parseDouble(json['baseSalary'], fallback: 0),
      commissionRate: parseDouble(json['commissionRate'], fallback: 0.1),
      successRate: parseDouble(json['successRate'], fallback: 0.7),
      ongoingCases: parseInt(json['ongoingCases'], fallback: 0),
      bio: parseString(json['bio']),
      languages: List<String>.from(json['languages'] as List? ?? const []),
      certifications:
          List<String>.from(json['certifications'] as List? ?? const []),
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
      'specialization': specialization,
      'licenseNumber': licenseNumber,
      'experienceYears': experienceYears,
      'hourlyRate': hourlyRate,
      'baseSalary': baseSalary,
      'commissionRate': commissionRate,
      'successRate': successRate,
      'ongoingCases': ongoingCases,
      'bio': bio,
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
        languages,
        certifications,
        isActive,
        createdAt,
        updatedAt
      ];
}
