part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object> get props => [profile];
}

class ProfileUpdateLoading extends ProfileState {
  final UserProfile profile;

  const ProfileUpdateLoading(this.profile);

  @override
  List<Object> get props => [profile];
}

class ProfileUpdateSuccess extends ProfileState {
  final UserProfile profile;
  final String message;

  const ProfileUpdateSuccess(this.profile, this.message);

  @override
  List<Object> get props => [profile, message];
}

class PasswordChangeLoading extends ProfileState {
  final UserProfile profile;

  const PasswordChangeLoading(this.profile);

  @override
  List<Object> get props => [profile];
}

class PasswordChangeSuccess extends ProfileState {
  final UserProfile profile;
  final String message;

  const PasswordChangeSuccess(this.profile, this.message);

  @override
  List<Object> get props => [profile, message];
}

class ProfileFailure extends ProfileState {
  final String message;

  const ProfileFailure(this.message);

  @override
  List<Object> get props => [message];
}
