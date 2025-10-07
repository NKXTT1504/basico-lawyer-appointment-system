part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class GetProfileRequested extends ProfileEvent {
  const GetProfileRequested();
}

class UpdateProfileRequested extends ProfileEvent {
  final String fullName;
  final String phoneNumber;
  final String? address;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? occupation;
  final String? notes;

  const UpdateProfileRequested({
    required this.fullName,
    required this.phoneNumber,
    this.address,
    this.gender,
    this.dateOfBirth,
    this.occupation,
    this.notes,
  });

  @override
  List<Object> get props => [
        fullName,
        phoneNumber,
        address ?? '',
        gender ?? '',
        (dateOfBirth?.millisecondsSinceEpoch ?? 0),
        occupation ?? '',
        notes ?? ''
      ];
}

class ChangePasswordRequested extends ProfileEvent {
  final String oldPassword;
  final String newPassword;

  const ChangePasswordRequested({
    required this.oldPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [oldPassword, newPassword];
}
