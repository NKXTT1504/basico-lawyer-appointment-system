import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/network/api_services.dart';

class AdminApiService {
  // Users (admin): GET/POST/PUT basic CRUD
  Future<Response> getUsers({bool includeInactive = true}) async {
    return Api.users.get('/api/User', queryParameters: {
      'includeInactive': includeInactive,
    });
  }

  // Customer Management (through Users API)
  Future<Response> getCustomers({bool includeInactive = true}) async {
    return Api.users.get('/api/User', queryParameters: {
      'includeInactive': includeInactive,
      'role': 'Customer', // API uses 'Customer' with capital C
    });
  }

  Future<Response> getCustomerById(String id) async {
    return Api.users.get('/api/User/$id');
  }

  Future<Response> createCustomer(Map<String, dynamic> customerData) async {
    return Api.users.post('/api/User', data: json.encode(customerData));
  }

  Future<Response> updateCustomer(
      String id, Map<String, dynamic> customerData) async {
    return Api.users.put('/api/User/$id', data: json.encode(customerData));
  }

  Future<Response> deleteCustomer(String id) async {
    return Api.users.delete('/api/User/$id');
  }

  Future<Response> deactivateCustomer(String id) async {
    return Api.users.put('/api/User/$id/deactivate');
  }

  Future<Response> activateCustomer(String id) async {
    return Api.users.put('/api/User/$id/activate');
  }

  // Forms CRUD
  Future<Response> getForms() => Api.users.get('/api/Form');
  Future<Response> createForm(Map<String, dynamic> dto) =>
      Api.users.post('/api/Form', data: json.encode(dto));
  Future<Response> updateForm(int id, Map<String, dynamic> dto) =>
      Api.users.put('/api/Form/$id', data: json.encode(dto));
  Future<Response> deleteForm(int id) => Api.users.delete('/api/Form/$id');

  // Lawyers
  Future<Response> getAllLawyersProfile() =>
      Api.lawyers.get('/api/Lawyer/GetAllLawyerProfile');
  Future<Response> getLawyerById(int id) =>
      Api.lawyers.get('/api/Lawyer/GetProfileById/$id');
  Future<Response> updateLawyerProfileSaga(int id, Map<String, dynamic> dto) =>
      Api.lawyers
          .put('/api/Lawyer/UpdateLawyerProfile/$id', data: json.encode(dto));
  Future<Response> updateLawyerSimple(int id, Map<String, dynamic> dto) =>
      Api.lawyers.put('/api/Lawyer/$id', data: json.encode(dto));
  Future<Response> getLawyerSagaState(int id) =>
      Api.lawyers.get('/api/Lawyer/$id/saga-state');

  // Lawyer diplomas
  Future<Response> createLawyerDiploma(
          int lawyerId, Map<String, dynamic> dto) =>
      Api.lawyers
          .post('/api/LawyerDiploma/lawyer/$lawyerId', data: json.encode(dto));
  Future<Response> updateLawyerDiploma(int id, Map<String, dynamic> dto) =>
      Api.lawyers.put('/api/LawyerDiploma/$id', data: json.encode(dto));
  Future<Response> deleteLawyerDiploma(int id) =>
      Api.lawyers.delete('/api/LawyerDiploma/$id');

  // Practice areas & services (read-only for admin filters)
  Future<Response> getPracticeAreas() => Api.lawyers.get('/api/PracticeArea');
  Future<Response> getServices() => Api.lawyers.get('/api/Service');

  // Work slots
  Future<Response> getWorkSlots({required int lawyerId}) =>
      Api.lawyers.get('/api/WorkSlotAPI/by-lawyer/$lawyerId');

  // Appointments
  Future<Response> createAppointment(Map<String, dynamic> dto) =>
      Api.appointments.post('/api/Appointment/CREATE', data: json.encode(dto));
  Future<Response> completeAppointment(int id) =>
      Api.appointments.put('/api/Appointment/$id/complete');
  Future<Response> deleteAppointment(int id) =>
      Api.appointments.delete('/api/Appointment/$id');
  Future<Response> updateAppointment(int id, Map<String, dynamic> dto) => Api
      .appointments
      .put('/api/Appointment/UpdateAppointment/$id', data: json.encode(dto));
  Future<Response> getAppointmentSagaState(int id) =>
      Api.appointments.get('/api/Appointment/$id/saga-state');
  Future<Response> getAppointmentsJoined() =>
      Api.appointments.get('/api/AppointmentWithUserLawyer/GetAllAppointment');
}
