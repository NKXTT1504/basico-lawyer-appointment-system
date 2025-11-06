import '../../data/models/admin_user.dart';
import '../../data/models/appointment.dart';
import '../../../customer/data/models/customer.dart';
import '../../../lawyer/data/models/lawyer.dart';
import '../../data/services/admin_api_service.dart';
import '../../data/services/user_storage_service.dart';

class AdminDashboardController {
  final AdminApiService _apiService = AdminApiService();

  Future<Map<String, dynamic>> loadDashboardData() async {
    try {
      final user = await UserStorageService.getCurrentUser();
      if (user == null || user.role != UserRole.admin) {
        throw Exception('Unauthorized: Admin access required');
      }

      // Fetch data from API
      final customersResp = await _apiService.getCustomers();
      final lawyersResp = await _apiService.getUsersWithLawyerProfileOnly();
      final appointmentsResp = await _apiService.getAppointmentsJoined();

      // Parse API responses
      final customersData = customersResp.data['result'] as List? ?? [];
      final lawyersData = lawyersResp.data['result'] as List? ?? [];
      final appointmentsData = appointmentsResp.data['result'] as List? ?? [];

      // Convert to models
      final customers = customersData.map((json) {
        try {
          return Customer.fromJson(json);
        } catch (e) {
          print('❌ Customer parse error: $e');
          return Customer(
            id: (json['id'] ?? '').toString(),
            name: (json['fullName'] ?? json['name'] ?? 'Unknown').toString(),
            email: (json['email'] ?? '').toString(),
            phone: (json['phoneNumber'] ?? json['phone'] ?? '').toString(),
            address: (json['address'] ?? '').toString(),
            dateOfBirth: DateTime.now(),
            gender: 'Không xác định',
            occupation: 'Không xác định',
            notes: '',
            isActive: true,
            createdAt: DateTime.now(),
          );
        }
      }).toList();

      final lawyers = lawyersData.map((json) {
        try {
          final userData = json['user'] as Map<String, dynamic>;
          return Lawyer.fromJson(userData);
        } catch (e) {
          print('❌ Lawyer parse error: $e');
          return Lawyer(
            id: (json['user']?['id'] ?? '').toString(),
            name: (json['user']?['fullName'] ?? 'Unknown').toString(),
            email: (json['user']?['email'] ?? '').toString(),
            phone: (json['user']?['phoneNumber'] ?? '').toString(),
            address: '',
            specialization: '',
            licenseNumber: '',
            experienceYears: 0,
            hourlyRate: 0,
            createdAt: DateTime.now(),
          );
        }
      }).toList();

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

      // Get dashboard statistics
      Map<String, dynamic> stats = {};
      try {
        final statsResp = await _apiService.getDashboardStats();
        if (statsResp.statusCode == 200) {
          final body = statsResp.data;
          stats = (body is Map<String, dynamic>)
              ? (body['result'] as Map<String, dynamic>? ?? body)
              : <String, dynamic>{};
        }
      } catch (_) {}

      return {
        'user': user,
        'customers': customers,
        'lawyers': lawyers,
        'appointments': appointments,
        'stats': stats,
      };
    } catch (e) {
      throw Exception('Failed to load dashboard data: $e');
    }
  }
}
