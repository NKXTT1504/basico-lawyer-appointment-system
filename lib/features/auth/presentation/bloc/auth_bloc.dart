import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../admin/data/services/user_storage_service.dart';
import '../../../admin/data/models/admin_user.dart';
import '../../../admin/data/models/customer.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthStatusChecked>(_onAuthStatusChecked);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user =
          await UserStorageService.loginUser(event.email, event.password);
      if (user == null) {
        emit(AuthFailure('Email hoặc mật khẩu không đúng'));
        return;
      }
      await UserStorageService.setCurrentUser(user);
      emit(AuthSuccess({'role': user.role.name}));
    } catch (e) {
      emit(AuthFailure('Có lỗi xảy ra: $e'));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Prevent duplicate email
      final existing = await UserStorageService.getUserByEmail(event.email);
      if (existing != null) {
        emit(AuthFailure('Email đã tồn tại'));
        return;
      }

      // Create user with customer role
      final newUser = User(
        id: 'user_customer_${DateTime.now().millisecondsSinceEpoch}',
        email: event.email.trim().toLowerCase(),
        password: event.password,
        name: event.fullName,
        role: UserRole.customer,
        createdAt: DateTime.now(),
      );
      await UserStorageService.addUser(newUser);

      // Create Customer profile basic
      await UserStorageService.addCustomer(
        Customer(
          id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
          name: event.fullName,
          email: event.email.trim().toLowerCase(),
          phone: event.phoneNumber,
          address: '',
          dateOfBirth: DateTime(1990, 1, 1),
          gender: 'Khác',
          occupation: '',
          createdAt: DateTime.now(),
        ),
      );

      await UserStorageService.setCurrentUser(newUser);
      emit(AuthSuccess({'role': newUser.role.name}));
    } catch (e) {
      emit(AuthFailure('Có lỗi xảy ra: $e'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await UserStorageService.setCurrentUser(null);
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure('Đăng xuất thất bại: $e'));
    }
  }

  Future<void> _onAuthStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await UserStorageService.getCurrentUser();
      if (user == null) {
        emit(AuthInitial());
      } else {
        emit(AuthSuccess({'role': user.role.name}));
      }
    } catch (e) {
      emit(AuthFailure('Kiểm tra trạng thái đăng nhập thất bại: $e'));
    }
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // TODO: Implement forgot password logic
      // For now, simulate success after a delay
      await Future.delayed(const Duration(seconds: 2));
      emit(AuthSuccess({'message': 'Email đặt lại mật khẩu đã được gửi'}));
    } catch (e) {
      emit(AuthFailure('Có lỗi xảy ra. Vui lòng thử lại sau.'));
    }
  }
}
