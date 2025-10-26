import '../models/customer.dart';
import 'admin_api_service.dart';
import 'user_storage_service.dart';

class CustomerApiService {
  final AdminApiService _adminApiService;

  CustomerApiService(this._adminApiService);

  /// Fetch customers from API and sync with local storage
  Future<List<Customer>> fetchCustomersFromApi(
      {bool includeInactive = true}) async {
    try {
      final response =
          await _adminApiService.getCustomers(includeInactive: includeInactive);

      // Debug: Print response to see structure
      print('📊 Customers API Response: ${response.statusCode}');
      print('📄 Response data type: ${response.data.runtimeType}');
      print('📄 Response data: ${response.data}');

      if (response.statusCode == 200) {
        // Try to handle different response structures
        List<dynamic> apiCustomers;

        if (response.data is List) {
          apiCustomers = response.data as List;
        } else if (response.data is Map<String, dynamic>) {
          final Map<String, dynamic> data =
              response.data as Map<String, dynamic>;
          if (data.containsKey('result')) {
            apiCustomers = data['result'] as List? ?? [];
          } else if (data.containsKey('Result')) {
            apiCustomers = data['Result'] as List? ?? [];
          } else if (data.containsKey('data')) {
            apiCustomers = data['data'] as List? ?? [];
          } else {
            apiCustomers = [];
          }
        } else {
          apiCustomers = [];
        }

        print('📋 Extracted ${apiCustomers.length} customers from API');

        final List<Customer> customers = [];

        for (var apiCustomer in apiCustomers) {
          try {
            // Convert API user data to Customer model
            final customer = _convertApiUserToCustomer(apiCustomer);
            customers.add(customer);
          } catch (e) {
            print('Error converting API user to customer: $e');
            // Continue with other customers
          }
        }

        // Update local storage with fresh data from API
        await UserStorageService.saveCustomers(customers);
        return customers;
      } else {
        throw Exception('Failed to fetch customers: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching customers from API: $e');
      // Fallback to local storage
      return await UserStorageService.getCustomers();
    }
  }

  /// Create a new customer via API
  Future<Customer> createCustomerViaApi(Customer customer) async {
    try {
      final customerData = _convertCustomerToApiUser(customer);
      final response = await _adminApiService.createCustomer(customerData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final apiCustomer = response.data;
        final createdCustomer = _convertApiUserToCustomer(apiCustomer);

        // Add to local storage
        await UserStorageService.addCustomer(createdCustomer);
        return createdCustomer;
      } else {
        throw Exception('Failed to create customer: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating customer via API: $e');
      // Fallback to local storage only
      await UserStorageService.addCustomer(customer);
      return customer;
    }
  }

  /// Update customer via API
  Future<Customer> updateCustomerViaApi(Customer customer) async {
    try {
      final customerData = _convertCustomerToApiUser(customer);
      final response =
          await _adminApiService.updateCustomer(customer.id, customerData);

      if (response.statusCode == 200) {
        final apiCustomer = response.data;
        final updatedCustomer = _convertApiUserToCustomer(apiCustomer);

        // Update local storage
        await UserStorageService.updateCustomer(updatedCustomer);
        return updatedCustomer;
      } else {
        throw Exception('Failed to update customer: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating customer via API: $e');
      // Fallback to local storage only
      await UserStorageService.updateCustomer(customer);
      return customer;
    }
  }

  /// Delete customer via API
  Future<void> deleteCustomerViaApi(String customerId) async {
    try {
      final response = await _adminApiService.deleteCustomer(customerId);

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Remove from local storage
        await UserStorageService.deleteCustomer(customerId);
      } else {
        throw Exception('Failed to delete customer: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting customer via API: $e');
      // Fallback to local storage only
      await UserStorageService.deleteCustomer(customerId);
    }
  }

  /// Activate/Deactivate customer via API
  Future<Customer> toggleCustomerStatusViaApi(
      String customerId, bool activate) async {
    try {
      final response = activate
          ? await _adminApiService.activateCustomer(customerId)
          : await _adminApiService.deactivateCustomer(customerId);

      if (response.statusCode == 200) {
        final apiCustomer = response.data;
        final updatedCustomer = _convertApiUserToCustomer(apiCustomer);

        // Update local storage
        await UserStorageService.updateCustomer(updatedCustomer);
        return updatedCustomer;
      } else {
        throw Exception(
            'Failed to ${activate ? 'activate' : 'deactivate'} customer: ${response.statusCode}');
      }
    } catch (e) {
      print('Error toggling customer status via API: $e');
      // Fallback to local storage only
      final customers = await UserStorageService.getCustomers();
      final customer = customers.firstWhere((c) => c.id == customerId);
      final updatedCustomer = customer.copyWith(isActive: activate);
      await UserStorageService.updateCustomer(updatedCustomer);
      return updatedCustomer;
    }
  }

  /// Convert API user data to Customer model
  Customer _convertApiUserToCustomer(Map<String, dynamic> apiUser) {
    return Customer(
      id: apiUser['id']?.toString() ?? '',
      name: apiUser['fullName'] ?? apiUser['name'] ?? '',
      email: apiUser['email'] ?? '',
      phone: apiUser['phoneNumber'] ?? apiUser['phone'] ?? '',
      address: apiUser['address'] ?? '',
      dateOfBirth: apiUser['dateOfBirth'] != null
          ? DateTime.parse(apiUser['dateOfBirth'].toString())
          : DateTime.now().subtract(
              const Duration(days: 365 * 25)), // Default to 25 years ago
      gender: apiUser['gender'] ?? 'Nam',
      occupation: apiUser['occupation'] ?? '',
      notes: apiUser['notes'] ?? '',
      isActive: apiUser['isActive'] ?? true,
      createdAt: apiUser['createdAt'] != null
          ? DateTime.parse(apiUser['createdAt'].toString())
          : DateTime.now(),
      updatedAt: apiUser['updatedAt'] != null
          ? DateTime.parse(apiUser['updatedAt'].toString())
          : null,
    );
  }

  /// Convert Customer model to API user data format
  Map<String, dynamic> _convertCustomerToApiUser(Customer customer) {
    return {
      'fullName': customer.name,
      'email': customer.email,
      'phoneNumber': customer.phone,
      'address': customer.address,
      'dateOfBirth': customer.dateOfBirth.toIso8601String(),
      'gender': customer.gender,
      'occupation': customer.occupation,
      'notes': customer.notes,
      'isActive': customer.isActive,
      'role': 'customer',
    };
  }
}
