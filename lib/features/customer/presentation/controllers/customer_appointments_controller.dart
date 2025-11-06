import '../../../appointment/data/models/appointment_model.dart';
import '../../../appointment/data/services/appointment_api_service.dart';
import '../../../admin/data/services/user_storage_service.dart';

class CustomerAppointmentsController {
  Future<List<AppointmentModel>> getCustomerAppointments() async {
    try {
      final user = await UserStorageService.getCurrentUser();
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Fetch appointments for the current customer
      final response = await AppointmentApiService.getAllAppointments();
      final data = response.data['result'] as List? ?? [];
      // Filter appointments by current user ID
      final userAppointments = data.where((json) {
        final userId = json['userId']?.toString() ?? '';
        return userId == user.id;
      }).toList();

      return userAppointments
          .map((json) => AppointmentModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load appointments: $e');
    }
  }

  Future<AppointmentModel> getAppointmentById(String id) async {
    try {
      // Get all appointments and find the one with matching ID
      final response = await AppointmentApiService.getAllAppointments();
      final data = response.data['result'] as List? ?? [];
      final appointment = data.firstWhere(
        (json) => json['id']?.toString() == id,
        orElse: () => throw Exception('Appointment not found'),
      );
      return AppointmentModel.fromJson(appointment as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load appointment: $e');
    }
  }

  Future<void> createAppointment(Map<String, dynamic> appointmentData) async {
    try {
      await AppointmentApiService.createAppointment(appointmentData);
    } catch (e) {
      throw Exception('Failed to create appointment: $e');
    }
  }

  Future<void> cancelAppointment(String id) async {
    try {
      await AppointmentApiService.cancelAppointment(id);
    } catch (e) {
      throw Exception('Failed to cancel appointment: $e');
    }
  }
}
