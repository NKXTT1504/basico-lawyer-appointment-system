import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';
import '../../../admin/data/services/user_storage_service.dart';
import '../../../admin/data/models/admin_user.dart' as admin_model;
import '../../domain/entities/user_role.dart' as profile_role;

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
      // Map current logged-in user + customer profile from storage to UserProfile
      final user = await UserStorageService.getCurrentUser();
      if (user == null) {
        throw Exception('Chưa đăng nhập');
      }
      final customer = await UserStorageService.getCurrentCustomerProfile();
      final profile = UserProfile(
        id: customer?.id ?? user.id,
        email: user.email,
        fullName: customer?.name ?? user.name,
        phoneNumber: customer?.phone ?? '',
        role: _mapRole(user.role),
        createdAt: customer?.createdAt,
        updatedAt: customer?.updatedAt,
      );
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
        // Update customer entity in storage
        final customer = await UserStorageService.getCurrentCustomerProfile();
        if (customer != null) {
          await UserStorageService.updateCustomer(
            customer.copyWith(
              name: event.fullName,
              phone: event.phoneNumber,
              address: event.address ?? customer.address,
              gender: event.gender ?? customer.gender,
              dateOfBirth: event.dateOfBirth ?? customer.dateOfBirth,
              occupation: event.occupation ?? customer.occupation,
              // notes removed from customer-facing profile form
              updatedAt: DateTime.now(),
            ),
          );
          // Keep user account display name in sync for sidebar/header
          final user = await UserStorageService.getCurrentUser();
          if (user != null) {
            await UserStorageService.syncCustomerUserAccount(
              oldEmail: user.email,
              name: event.fullName,
              newEmail: user.email,
            );
            // Refresh current user cache to reflect new name immediately
            final refreshed =
                await UserStorageService.getUserByEmail(user.email);
            if (refreshed != null) {
              await UserStorageService.setCurrentUser(refreshed);
            }
          }
        }

        final resultProfile = currentProfile.copyWith(
          fullName: event.fullName,
          phoneNumber: event.phoneNumber,
          updatedAt: DateTime.now(),
        );
        emit(ProfileUpdateSuccess(
            resultProfile, 'Thông tin đã được cập nhật thành công!'));
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
        // Validate old password against current user
        final user = await UserStorageService.getCurrentUser();
        if (user == null) throw Exception('Chưa đăng nhập');
        if (user.password != event.oldPassword) {
          emit(ProfileFailure('Mật khẩu cũ không đúng!'));
          return;
        }
        await UserStorageService.updateUserPasswordByEmail(
            user.email, event.newPassword);
        emit(PasswordChangeSuccess(
            currentProfile, 'Mật khẩu đã được thay đổi thành công!'));
      } catch (e) {
        emit(ProfileFailure('Không thể thay đổi mật khẩu: ${e.toString()}'));
      }
    }
  }
}

profile_role.UserRole _mapRole(admin_model.UserRole role) {
  switch (role) {
    case admin_model.UserRole.customer:
      return profile_role.UserRole.customer;
    case admin_model.UserRole.lawyer:
      return profile_role.UserRole.lawyer;
    case admin_model.UserRole.admin:
      return profile_role.UserRole.admin;
  }
}
