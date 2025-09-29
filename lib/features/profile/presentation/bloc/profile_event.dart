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

  const UpdateProfileRequested({
    required this.fullName,
    required this.phoneNumber,
  });

  @override
  List<Object> get props => [fullName, phoneNumber];
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