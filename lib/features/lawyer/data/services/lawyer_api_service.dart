import 'package:dio/dio.dart';
import '../../../../core/network/api_services.dart';

class LawyerApiService {
  // Get all lawyers - từ Swagger Lawyers API v1
  static Future<Response> getLawyers() async {
    return await Api.lawyers.get('/api/Lawyer/GetAllLawyerProfile');
  }

  // Get lawyer by ID
  static Future<Response> getLawyerById(String lawyerId) async {
    return await Api.lawyers.get('/api/Lawyer/GetProfileById/$lawyerId');
  }

  // Get lawyer by user ID
  static Future<Response> getLawyerByUserId(String userId) async {
    return await Api.lawyers.get('/api/Lawyer/GetProfileByUserId/$userId');
  }

  // Update lawyer profile
  static Future<Response> updateLawyerProfile(
      String lawyerId, Map<String, dynamic> lawyerData) async {
    return await Api.lawyers
        .put('/api/Lawyer/UpdateLawyerProfile/$lawyerId', data: lawyerData);
  }

  // Update lawyer by lawyer ID
  static Future<Response> updateLawyerByLawyerId(
      String lawyerId, Map<String, dynamic> lawyerData) async {
    return await Api.lawyers
        .put('/api/Lawyer/UpdateLawyerByLaywerId/$lawyerId', data: lawyerData);
  }
}
