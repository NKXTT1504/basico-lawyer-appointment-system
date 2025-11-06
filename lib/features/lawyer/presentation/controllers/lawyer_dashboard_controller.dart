import '../../../admin/data/models/admin_user.dart';
import '../../../admin/data/models/appointment.dart';
import '../../../admin/data/services/admin_api_service.dart';
import '../../../admin/data/services/user_storage_service.dart';

class LawyerDashboardController {
  final AdminApiService _apiService = AdminApiService();

  Future<Map<String, dynamic>> loadDashboardData() async {
    try {
      final user = await UserStorageService.getCurrentUser();
      if (user == null || user.role != UserRole.lawyer) {
        throw Exception('Unauthorized: Lawyer access required');
      }

      // Get lawyer profile to get lawyer ID
      // Assuming user.id contains the lawyer profile ID or we need to fetch it
      // This is a simplified version - you may need to adjust based on your actual API structure

      // For now, we'll need to get the lawyer ID from the user
      // This is a placeholder - adjust based on your actual data structure
      final lawyerId = int.tryParse(user.id) ?? 0;

      if (lawyerId == 0) {
        throw Exception('Lawyer ID not found');
      }

      // Fetch appointments for this lawyer
      final appointmentsResp = await _apiService.getAppointmentsByLawyer(
        lawyerId: lawyerId,
      );

      final appointmentsData = appointmentsResp.data['result'] as List? ?? [];
      final appointments = appointmentsData.map((json) {
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

      return {
        'user': user,
        'appointments': appointments,
      };
    } catch (e) {
      throw Exception('Failed to load dashboard data: $e');
    }
  }
}
