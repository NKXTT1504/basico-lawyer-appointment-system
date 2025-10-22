import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/lawyer.dart';
import '../models/appointment.dart';

class AdminApiService {
  final Dio _usersDio;
  final Dio _lawyersDio;
  final Dio _appointmentsDio;

  AdminApiService()
      : _usersDio = Dio(BaseOptions(
          baseUrl: AppConstants.usersBaseUrl,
          connectTimeout: AppConstants.apiTimeout,
          receiveTimeout: AppConstants.apiTimeout,
        )),
        _lawyersDio = Dio(BaseOptions(
          baseUrl: AppConstants.lawyersBaseUrl,
          connectTimeout: AppConstants.apiTimeout,
          receiveTimeout: AppConstants.apiTimeout,
        )),
        _appointmentsDio = Dio(BaseOptions(
          baseUrl: AppConstants.appointmentsBaseUrl,
          connectTimeout: AppConstants.apiTimeout,
          receiveTimeout: AppConstants.apiTimeout,
        )) {
    _setupAuth(_usersDio);
    _setupAuth(_lawyersDio);
    _setupAuth(_appointmentsDio);
  }

  Future<void> _setupAuth(Dio dio) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    dio.interceptors.clear();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      options.headers['Content-Type'] = 'application/json';
      options.headers['Accept'] = 'application/json';
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    }));

    // Accept self-signed cert for localhost during development
    try {
      final adapter = dio.httpClientAdapter;
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

  // Users (admin): GET/POST/PUT basic CRUD
  Future<Response> getUsers({bool includeInactive = true}) async {
    return _usersDio.get('/api/User', queryParameters: {
      'includeInactive': includeInactive,
    });
  }

  // Forms CRUD
  Future<Response> getForms() => _usersDio.get('/api/Form');
  Future<Response> createForm(Map<String, dynamic> dto) =>
      _usersDio.post('/api/Form', data: json.encode(dto));
  Future<Response> updateForm(int id, Map<String, dynamic> dto) =>
      _usersDio.put('/api/Form/$id', data: json.encode(dto));
  Future<Response> deleteForm(int id) => _usersDio.delete('/api/Form/$id');

  // Lawyers
  Future<Response> getAllLawyersProfile() =>
      _lawyersDio.get('/api/Lawyer/GetAllLawyerProfile');
  Future<Response> getLawyerById(int id) =>
      _lawyersDio.get('/api/Lawyer/GetProfileById/$id');
  Future<Response> updateLawyerProfileSaga(int id, Map<String, dynamic> dto) =>
      _lawyersDio.put('/api/Lawyer/UpdateLawyerProfile/$id',
          data: json.encode(dto));
  Future<Response> updateLawyerSimple(int id, Map<String, dynamic> dto) =>
      _lawyersDio.put('/api/Lawyer/$id', data: json.encode(dto));
  Future<Response> getLawyerSagaState(int id) =>
      _lawyersDio.get('/api/Lawyer/$id/saga-state');

  // Lawyer diplomas
  Future<Response> createLawyerDiploma(int lawyerId, Map<String, dynamic> dto) =>
      _lawyersDio.post('/api/LawyerDiploma/lawyer/$lawyerId',
          data: json.encode(dto));
  Future<Response> updateLawyerDiploma(int id, Map<String, dynamic> dto) =>
      _lawyersDio.put('/api/LawyerDiploma/$id', data: json.encode(dto));
  Future<Response> deleteLawyerDiploma(int id) =>
      _lawyersDio.delete('/api/LawyerDiploma/$id');

  // Practice areas & services (read-only for admin filters)
  Future<Response> getPracticeAreas() =>
      _lawyersDio.get('/api/PracticeArea');
  Future<Response> getServices() => _lawyersDio.get('/api/Service');

  // Work slots
  Future<Response> getWorkSlots({required int lawyerId}) =>
      _lawyersDio.get('/api/WorkSlotAPI/by-lawyer/$lawyerId');

  // Appointments
  Future<Response> createAppointment(Map<String, dynamic> dto) =>
      _appointmentsDio.post('/api/Appointment/CREATE',
          data: json.encode(dto));
  Future<Response> completeAppointment(int id) =>
      _appointmentsDio.put('/api/Appointment/$id/complete');
  Future<Response> deleteAppointment(int id) =>
      _appointmentsDio.delete('/api/Appointment/$id');
  Future<Response> updateAppointment(int id, Map<String, dynamic> dto) =>
      _appointmentsDio.put('/api/Appointment/UpdateAppointment/$id',
          data: json.encode(dto));
  Future<Response> getAppointmentSagaState(int id) =>
      _appointmentsDio.get('/api/Appointment/$id/saga-state');
  Future<Response> getAppointmentsJoined() => _appointmentsDio
      .get('/api/AppointmentWithUserLawyer/GetAllAppointment');
}


