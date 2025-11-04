import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'api_client.dart';

// API URLs - từ Swagger documentation
const Map<String, String> API_URLS = {
  'USERS':
      'https://localhost:5000', // Users API v1 - Gateway routes to Users service
  'LAWYERS':
      'https://localhost:5000', // Lawyers API v1 - Gateway routes to Lawyers service
  'APPOINTMENTS':
      'https://localhost:5000', // Appointments API v1 - Gateway routes to Appointments service
  'CHAT':
      'https://localhost:5000', // Chat API v1 - Gateway routes to Chat service
};

// Create API instances giống web app
class ApiServices {
  static final ApiClient _apiClient = GetIt.instance<ApiClient>();

  // Users API - từ Swagger Users API v1
  static Future<Response> usersGet(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) {
    return _apiClient.get('${API_URLS['USERS']}/api/users$path',
        queryParameters: queryParameters, options: options);
  }

  static Future<Response> usersPost(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _apiClient.post('${API_URLS['USERS']}/api/users$path',
        data: data, queryParameters: queryParameters, options: options);
  }

  static Future<Response> usersPut(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _apiClient.put('${API_URLS['USERS']}/api/users$path',
        data: data, queryParameters: queryParameters, options: options);
  }

  static Future<Response> usersDelete(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _apiClient.delete('${API_URLS['USERS']}/api/users$path',
        data: data, queryParameters: queryParameters, options: options);
  }

  // Appointments API - từ Swagger Appointments API v1
  // Base URL là gateway, tất cả appointments endpoints cần prefix /api/appointments
  static Future<Response> appointmentsGet(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) {
    return _apiClient.get('${API_URLS['APPOINTMENTS']}/api/appointments$path',
        queryParameters: queryParameters, options: options);
  }

  static Future<Response> appointmentsPost(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    // Tất cả appointments endpoints cần prefix /api/appointments
    return _apiClient.post('${API_URLS['APPOINTMENTS']}/api/appointments$path',
        data: data, queryParameters: queryParameters, options: options);
  }

  static Future<Response> appointmentsPut(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    // Tất cả appointments endpoints cần prefix /api/appointments
    return _apiClient.put('${API_URLS['APPOINTMENTS']}/api/appointments$path',
        data: data, queryParameters: queryParameters, options: options);
  }

  static Future<Response> appointmentsDelete(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    // Tất cả appointments endpoints cần prefix /api/appointments
    return _apiClient.delete(
        '${API_URLS['APPOINTMENTS']}/api/appointments$path',
        data: data,
        queryParameters: queryParameters,
        options: options);
  }

  // Lawyers API - từ Swagger Lawyers API v1
  static Future<Response> lawyersGet(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) {
    return _apiClient.get('${API_URLS['LAWYERS']}/api/lawyers$path',
        queryParameters: queryParameters, options: options);
  }

  // WorkSlotAPI - không nằm trong /api/lawyers, gọi trực tiếp
  static Future<Response> workSlotGet(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) {
    return _apiClient.get('${API_URLS['LAWYERS']}$path',
        queryParameters: queryParameters, options: options);
  }

  static Future<Response> lawyersPost(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _apiClient.post('${API_URLS['LAWYERS']}/api/lawyers$path',
        data: data, queryParameters: queryParameters, options: options);
  }

  static Future<Response> lawyersPut(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _apiClient.put('${API_URLS['LAWYERS']}/api/lawyers$path',
        data: data, queryParameters: queryParameters, options: options);
  }

  static Future<Response> lawyersDelete(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _apiClient.delete('${API_URLS['LAWYERS']}/api/lawyers$path',
        data: data, queryParameters: queryParameters, options: options);
  }

  // Chat API - từ Swagger Chat API v1
  // Swagger URL: https://localhost:5000/api/chat/api/Chat
  // Base URL: /api/chat, endpoint: /api/Chat/...
  static Future<Response> chatGet(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) {
    return _apiClient.get('${API_URLS['CHAT']}/api/chat$path',
        queryParameters: queryParameters, options: options);
  }

  static Future<Response> chatPost(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _apiClient.post('${API_URLS['CHAT']}/api/chat$path',
        data: data, queryParameters: queryParameters, options: options);
  }

  static Future<Response> chatPut(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _apiClient.put('${API_URLS['CHAT']}/api/chat$path',
        data: data, queryParameters: queryParameters, options: options);
  }

  static Future<Response> chatDelete(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return _apiClient.delete('${API_URLS['CHAT']}/api/chat$path',
        data: data, queryParameters: queryParameters, options: options);
  }
}

// Export instances từ Swagger APIs
class Api {
  static final users = _UsersApi();
  static final lawyers = _LawyersApi();
  static final appointments = _AppointmentsApi();
  static final chat = _ChatApi();
}

class _UsersApi {
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) {
    return ApiServices.usersGet(path,
        queryParameters: queryParameters, options: options);
  }

  Future<Response> post(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return ApiServices.usersPost(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> put(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return ApiServices.usersPut(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> delete(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return ApiServices.usersDelete(path,
        data: data, queryParameters: queryParameters, options: options);
  }
}

class _LawyersApi {
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) {
    return ApiServices.lawyersGet(path,
        queryParameters: queryParameters, options: options);
  }

  Future<Response> post(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return ApiServices.lawyersPost(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> put(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return ApiServices.lawyersPut(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> delete(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return ApiServices.lawyersDelete(path,
        data: data, queryParameters: queryParameters, options: options);
  }
}

class _AppointmentsApi {
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) {
    return ApiServices.appointmentsGet(path,
        queryParameters: queryParameters, options: options);
  }

  Future<Response> post(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return ApiServices.appointmentsPost(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> put(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return ApiServices.appointmentsPut(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> delete(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return ApiServices.appointmentsDelete(path,
        data: data, queryParameters: queryParameters, options: options);
  }
}

class _ChatApi {
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) {
    return ApiServices.chatGet(path,
        queryParameters: queryParameters, options: options);
  }

  Future<Response> post(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return ApiServices.chatPost(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> put(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return ApiServices.chatPut(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> delete(String path,
      {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) {
    return ApiServices.chatDelete(path,
        data: data, queryParameters: queryParameters, options: options);
  }
}
