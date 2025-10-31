import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_profile.dart';
import '../../../admin/data/services/user_storage_service.dart';
import '../../../admin/data/models/admin_user.dart' as admin_model;
import '../../domain/entities/user_role.dart' as profile_role;
import '../../../auth/data/services/auth_api_service.dart';

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
      // Get current logged-in user
      final user = await UserStorageService.getCurrentUser();
      if (user == null) {
        throw Exception('Chưa đăng nhập');
      }

      // Try to get user data from stored login response first
      try {
        final prefs = await SharedPreferences.getInstance();
        final String? userDataStr = prefs.getString('user_data');
        if (userDataStr != null) {
          final userData = json.decode(userDataStr) as Map<String, dynamic>;
          final profile = UserProfile(
            id: user.id,
            email: userData['email'] ?? userData['Email'] ?? user.email,
            fullName: userData['fullName'] ??
                userData['FullName'] ??
                userData['name'] ??
                user.name,
            phoneNumber: userData['phoneNumber'] ??
                userData['PhoneNumber'] ??
                userData['phone'] ??
                '',
            role: _mapRole(user.role),
            createdAt: userData['createdAt'] != null
                ? DateTime.parse(userData['createdAt'])
                : user.createdAt,
            updatedAt: userData['updatedAt'] != null
                ? DateTime.parse(userData['updatedAt'])
                : null,
          );
          emit(ProfileLoaded(profile));
          return;
        }
      } catch (e) {
        print('Stored user data fetch failed: $e');
      }

      // Try to fetch user profile from API as fallback
      try {
        final response = await AuthApiService.getUserProfile(user.id);
        if (response.statusCode == 200) {
          final userData = response.data as Map<String, dynamic>;
          final profile = UserProfile(
            id: user.id,
            email: userData['email'] ?? userData['Email'] ?? user.email,
            fullName: userData['fullName'] ??
                userData['FullName'] ??
                userData['name'] ??
                user.name,
            phoneNumber: userData['phoneNumber'] ??
                userData['PhoneNumber'] ??
                userData['phone'] ??
                '',
            role: _mapRole(user.role),
            createdAt: userData['createdAt'] != null
                ? DateTime.parse(userData['createdAt'])
                : user.createdAt,
            updatedAt: userData['updatedAt'] != null
                ? DateTime.parse(userData['updatedAt'])
                : null,
          );
          emit(ProfileLoaded(profile));
          return;
        }
      } catch (e) {
        print('API fetch failed, falling back to local storage: $e');
      }

      // Fallback to local storage
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
        // Try to update via API first
        try {
          final user = await UserStorageService.getCurrentUser();
          if (user != null) {
            final updateData = {
              'FullName': event.fullName,
              'PhoneNumber': event.phoneNumber,
              if (event.address != null) 'Address': event.address,
              if (event.gender != null) 'Gender': event.gender,
              if (event.dateOfBirth != null)
                'DateOfBirth': event.dateOfBirth!.toIso8601String(),
              if (event.occupation != null) 'Occupation': event.occupation,
            };

            final response =
                await AuthApiService.updateUserProfile(user.id, updateData);
            if (response.statusCode == 200) {
              final resultProfile = currentProfile.copyWith(
                fullName: event.fullName,
                phoneNumber: event.phoneNumber,
                updatedAt: DateTime.now(),
              );
              emit(ProfileUpdateSuccess(
                  resultProfile, 'Thông tin đã được cập nhật thành công!'));
              return;
            }
          }
        } catch (e) {
          print('API update failed, falling back to local storage: $e');
        }

        // Fallback to local storage update
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
        final user = await UserStorageService.getCurrentUser();
        if (user == null) throw Exception('Chưa đăng nhập');

        // Try to change password via API first; if it fails, show error instead
        try {
          final response = await AuthApiService.changePassword(
              user.id, event.oldPassword, event.newPassword);
          if (response.statusCode == 200) {
            emit(PasswordChangeSuccess(
                currentProfile, 'Mật khẩu đã được thay đổi thành công!'));
            return;
          } else {
            emit(ProfileFailure('Đổi mật khẩu thất bại. Vui lòng thử lại.'));
            return;
          }
        } catch (e) {
          emit(ProfileFailure('Đổi mật khẩu thất bại: ${e.toString()}'));
          return;
        }
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
