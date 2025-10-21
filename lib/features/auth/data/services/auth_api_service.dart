import 'package:dio/dio.dart';
import '../../../../core/network/api_services.dart';

class AuthApiService {
  // Login - từ Swagger Users API v1
  static Future<Response> login(String email, String password) async {
    return await Api.users.post('/api/Auth/login', data: {
      'Email': email,
      'Password': password,
    });
  }

  // Register - từ Swagger Users API v1
  static Future<Response> register(Map<String, dynamic> userData) async {
    return await Api.users.post('/api/Auth/register', data: userData);
  }

  // Get user profile
  static Future<Response> getUserProfile(String userId) async {
    return await Api.users.get('/$userId');
  }

  // Update user profile
  static Future<Response> updateUserProfile(
      String userId, Map<String, dynamic> profileData) async {
    return await Api.users.put('/api/Auth/update/$userId', data: profileData);
  }

  // Change password
  static Future<Response> changePassword(
      String userId, String currentPassword, String newPassword) async {
    return await Api.users.put('/api/Auth/update/$userId', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  // Forgot password
  static Future<Response> forgotPassword(String email) async {
    return await Api.users.post('/api/Auth/forgot-password', data: {
      'email': email,
    });
  }

  // Reset password
  static Future<Response> resetPassword(
      String token, String newPassword) async {
    return await Api.users.post('/api/Auth/reset-password', data: {
      'token': token,
      'newPassword': newPassword,
    });
  }
}
