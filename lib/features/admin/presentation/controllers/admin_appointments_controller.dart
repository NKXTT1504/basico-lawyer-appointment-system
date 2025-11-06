import '../../data/models/appointment.dart';
import '../../data/services/admin_api_service.dart';

class AdminAppointmentsController {
  final AdminApiService _apiService = AdminApiService();

  Future<List<Appointment>> getAllAppointments() async {
    try {
      final response = await _apiService.getAppointmentsJoined();
      final data = response.data['result'] as List? ?? [];
      return data.map((json) {
        try {
          return Appointment.fromJson(json);
        } catch (e) {
          print('❌ Appointment parse error: $e');
          return Appointment(
            id: (json['id'] ?? '').toString(),
            customerId: (json['userId'] ?? '').toString(),
            customerName: (json['user']?['fullName'] ?? 'Unknown').toString(),
            lawyerId: (json['lawyerId'] ?? '').toString(),
            lawyerName: 'Luật sư #${json['lawyerId'] ?? ''}',
            appointmentDate: DateTime.now(),
            timeSlot: (json['slot'] ?? '').toString(),
            duration: '60m',
            type: (json['spec'] ?? '').toString(),
            description: '',
            status: AppointmentStatus.pending,
            notes: '',
            fee: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      }).toList();
    } catch (e) {
      throw Exception('Failed to load appointments: $e');
    }
  }

  Future<List<Appointment>> getAppointmentsByLawyer(int lawyerId) async {
    try {
      final response = await _apiService.getAppointmentsByLawyer(
        lawyerId: lawyerId,
      );
      final data = response.data['result'] as List? ?? [];
      return data.map((json) => Appointment.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load appointments: $e');
    }
  }

  Future<void> createAppointment(Map<String, dynamic> appointmentData) async {
    try {
      await _apiService.createAppointment(appointmentData);
    } catch (e) {
      throw Exception('Failed to create appointment: $e');
    }
  }

  Future<void> updateAppointment(
      int id, Map<String, dynamic> appointmentData) async {
    try {
      await _apiService.updateAppointment(id, appointmentData);
    } catch (e) {
      throw Exception('Failed to update appointment: $e');
    }
  }

  Future<void> confirmAppointment(int id) async {
    try {
      await _apiService.confirmAppointment(id);
    } catch (e) {
      throw Exception('Failed to confirm appointment: $e');
    }
  }

  Future<void> cancelAppointment(int id) async {
    try {
      await _apiService.cancelAppointment(id);
    } catch (e) {
      throw Exception('Failed to cancel appointment: $e');
    }
  }

  Future<void> completeAppointment(int id) async {
    try {
      await _apiService.completeAppointment(id);
    } catch (e) {
      throw Exception('Failed to complete appointment: $e');
    }
  }

  Future<void> deleteAppointment(int id) async {
    try {
      await _apiService.deleteAppointment(id);
    } catch (e) {
      throw Exception('Failed to delete appointment: $e');
    }
  }
}

