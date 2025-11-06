import '../../../lawyer/data/models/lawyer.dart';
import '../../data/services/admin_api_service.dart';

class AdminLawyersController {
  final AdminApiService _apiService = AdminApiService();

  Future<List<Lawyer>> getAllLawyers() async {
    try {
      final response = await _apiService.getAllLawyersProfile();
      final data = response.data['result'] as List? ?? [];
      return data.map((json) {
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
    } catch (e) {
      throw Exception('Failed to load lawyers: $e');
    }
  }

  Future<Lawyer> getLawyerById(int id) async {
    try {
      final response = await _apiService.getLawyerById(id);
      final data = response.data['result'] ?? response.data;
      return Lawyer.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load lawyer: $e');
    }
  }

  Future<void> updateLawyerProfile(
      int id, Map<String, dynamic> lawyerData) async {
    try {
      await _apiService.updateLawyerProfileSaga(id, lawyerData);
    } catch (e) {
      throw Exception('Failed to update lawyer: $e');
    }
  }

  Future<void> updateLawyerSimple(
      int id, Map<String, dynamic> lawyerData) async {
    try {
      await _apiService.updateLawyerSimple(id, lawyerData);
    } catch (e) {
      throw Exception('Failed to update lawyer: $e');
    }
  }
}
