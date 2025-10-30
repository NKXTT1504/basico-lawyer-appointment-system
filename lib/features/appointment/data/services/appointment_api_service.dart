import 'package:dio/dio.dart';
import '../../../../core/network/api_services.dart';

class AppointmentApiService {
  // Create appointment - từ Swagger Appointments API v1
  static Future<Response> createAppointment(
      Map<String, dynamic> appointmentData) async {
    return await Api.appointments
        .post('/api/Appointment/CREATE', data: appointmentData);
  }

  // Get all appointments with user and lawyer info
  static Future<Response> getAllAppointments() async {
    return await Api.appointments
        .get('/api/AppointmentWithUserLawyer/GetAllAppointment');
  }

  // Confirm appointment
  static Future<Response> confirmAppointment(String appointmentId) async {
    return await Api.appointments
        .put('/api/Appointment/$appointmentId/confirm');
  }

  // Cancel appointment
  static Future<Response> cancelAppointment(String appointmentId) async {
    return await Api.appointments.put('/api/Appointment/$appointmentId/cancel');
  }

  // Complete appointment
  static Future<Response> completeAppointment(String appointmentId) async {
    return await Api.appointments
        .put('/api/Appointment/$appointmentId/complete');
  }

  // Update appointment
  static Future<Response> updateAppointment(
      String appointmentId, Map<String, dynamic> appointmentData) async {
    return await Api.appointments.put(
        '/api/Appointment/UpdateAppointment/$appointmentId',
        data: appointmentData);
  }

  // Delete appointment
  static Future<Response> deleteAppointment(String appointmentId) async {
    return await Api.appointments.delete('/api/Appointment/$appointmentId');
  }
}

class PaymentApiService {
  // Gọi API tạo link thanh toán VNPay cho appointment
  static Future<Response> createVnpayPaymentUrl(
      Map<String, dynamic> paymentData) async {
    // Sử dụng URL đúng như swagger: /api/Payments/create-url-for-appointment
    return await Api.appointments
        .post('/api/Payments/create-url-for-appointment', data: paymentData);
  }
}
