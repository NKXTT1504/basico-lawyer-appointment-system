import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:dio/io.dart';

import '../constants/app_constants.dart';
import 'network_info.dart';

class ApiClient {
  final Dio _dio;
  final SharedPreferences _prefs;
  final NetworkInfo _networkInfo;

  ApiClient(this._dio, this._prefs, this._networkInfo) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.options.baseUrl = AppConstants.baseUrl;
    _dio.options.connectTimeout = AppConstants.apiTimeout;
    _dio.options.receiveTimeout = AppConstants.apiTimeout;
    _dio.options.sendTimeout = AppConstants.apiTimeout;

    // Request interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final token = _prefs.getString(AppConstants.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          // Add common headers
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';
          
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Handle unauthorized - clear token and redirect to login
            await _prefs.remove(AppConstants.tokenKey);
            // You might want to emit an event or use a global navigator here
          }
          handler.next(error);
        },
      ),
    );

    // Logging interceptor (only in debug mode)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) {
          // Use your preferred logging method
          print(object);
        },
      ),
    );

    // Accept self-signed cert for localhost during development
    try {
      final adapter = _dio.httpClientAdapter;
      if (adapter is IOHttpClientAdapter) {
        adapter.createHttpClient = () {
          final client = HttpClient();
          client.badCertificateCallback = (cert, host, port) {
            return host == 'localhost' || host == '10.0.2.2';
          };
          return client;
        };
      }
    } catch (_) {}
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (!await _networkInfo.isConnected) {
      throw Exception('No internet connection');
    }
    
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (!await _networkInfo.isConnected) {
      throw Exception('No internet connection');
    }
    
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (!await _networkInfo.isConnected) {
      throw Exception('No internet connection');
    }
    
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (!await _networkInfo.isConnected) {
      throw Exception('No internet connection');
    }
    
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
