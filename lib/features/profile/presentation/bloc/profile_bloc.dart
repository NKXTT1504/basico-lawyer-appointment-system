import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';
import '../../data/mock_data/profile_mock_data.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<GetProfileRequested>(_onGetProfileRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
  }

  Future<void> _onGetProfileRequested(
    GetProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profile = await ProfileMockData.getCurrentUserProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileFailure('Không thể tải thông tin cá nhân: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentProfile = (state as ProfileLoaded).profile;
      emit(ProfileUpdateLoading(currentProfile));
      
      try {
        final updatedProfile = currentProfile.copyWith(
          fullName: event.fullName,
          phoneNumber: event.phoneNumber,
        );
        
        final resultProfile = await ProfileMockData.updateProfile(updatedProfile);
        emit(ProfileUpdateSuccess(resultProfile, 'Thông tin đã được cập nhật thành công!'));
      } catch (e) {
        emit(ProfileFailure('Không thể cập nhật thông tin: ${e.toString()}'));
      }
    }
  }

  Future<void> _onChangePasswordRequested(
    ChangePasswordRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentProfile = (state as ProfileLoaded).profile;
      emit(PasswordChangeLoading(currentProfile));
      
      try {
        final success = await ProfileMockData.changePassword(
          event.oldPassword,
          event.newPassword,
        );
        
        if (success) {
          emit(PasswordChangeSuccess(currentProfile, 'Mật khẩu đã được thay đổi thành công!'));
        } else {
          emit(ProfileFailure('Mật khẩu cũ không đúng!'));
        }
      } catch (e) {
        emit(ProfileFailure('Không thể thay đổi mật khẩu: ${e.toString()}'));
      }
    }
  }
}
