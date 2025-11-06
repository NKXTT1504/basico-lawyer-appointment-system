import '../../../customer/data/models/customer.dart';
import '../../data/services/admin_api_service.dart';

class AdminCustomersController {
  final AdminApiService _apiService = AdminApiService();

  Future<List<Customer>> getCustomers({bool includeInactive = true}) async {
    try {
      final response = await _apiService.getCustomers(
        includeInactive: includeInactive,
      );
      final data = response.data['result'] as List? ?? [];
      return data.map((json) => Customer.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load customers: $e');
    }
  }

  Future<Customer> getCustomerById(String id) async {
    try {
      final response = await _apiService.getCustomerById(id);
      final data = response.data['result'] ?? response.data;
      return Customer.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to load customer: $e');
    }
  }

  Future<void> createCustomer(Map<String, dynamic> customerData) async {
    try {
      await _apiService.createCustomer(customerData);
    } catch (e) {
      throw Exception('Failed to create customer: $e');
    }
  }

  Future<void> updateCustomer(
      String id, Map<String, dynamic> customerData) async {
    try {
      await _apiService.updateCustomer(id, customerData);
    } catch (e) {
      throw Exception('Failed to update customer: $e');
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _apiService.deleteCustomer(id);
    } catch (e) {
      throw Exception('Failed to delete customer: $e');
    }
  }

  Future<void> softDeleteCustomer(String id) async {
    try {
      await _apiService.softDeleteUser(id);
    } catch (e) {
      throw Exception('Failed to soft delete customer: $e');
    }
  }

  Future<void> restoreCustomer(String id) async {
    try {
      await _apiService.restoreUser(id);
    } catch (e) {
      throw Exception('Failed to restore customer: $e');
    }
  }
}
