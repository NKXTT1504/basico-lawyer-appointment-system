import '../models/customer.dart';
import '../../../admin/data/services/admin_api_service.dart';
import '../../../admin/data/services/user_storage_service.dart';

class CustomerApiService {
  final AdminApiService _adminApiService;

  CustomerApiService(this._adminApiService);

  /// Fetch customers from API and sync with local storage
  Future<List<Customer>> fetchCustomersFromApi(
      {bool includeInactive = true}) async {
    try {
      print('🔄 Fetching customers from API...');
      print(
          '🔗 API URL: https://localhost:5000/api/users/api/User?includeInactive=$includeInactive&role=customer');

      final response =
          await _adminApiService.getCustomers(includeInactive: includeInactive);

      // Debug: Print response to see structure
      print('📊 Customers API Response: ${response.statusCode}');
      print('📄 Response data type: ${response.data.runtimeType}');
      print('📄 Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Try to handle different response structures
        List<dynamic> allUsers;

        if (response.data is List) {
          allUsers = response.data as List;
        } else if (response.data is Map<String, dynamic>) {
          final Map<String, dynamic> data =
              response.data as Map<String, dynamic>;
          if (data.containsKey('result')) {
            allUsers = data['result'] as List? ?? [];
          } else if (data.containsKey('Result')) {
            allUsers = data['Result'] as List? ?? [];
          } else if (data.containsKey('data')) {
            allUsers = data['data'] as List? ?? [];
          } else {
            allUsers = [];
          }
        } else {
          allUsers = [];
        }

        print('📋 Extracted ${allUsers.length} total users from API');

        // Filter for customers only (role: 'Customer' or 'CUSTOMER')
        final apiCustomers = allUsers.where((user) {
          final role = user['role']?.toString().toLowerCase() ?? '';
          return role == 'customer';
        }).toList();

        print('📋 Filtered to ${apiCustomers.length} customers');

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
    } catch (e, stackTrace) {
      print('❌ Error fetching customers from API: $e');
      print('Stack trace: $stackTrace');

      // Check if it's a network error
      if (e.toString().contains('SocketException') ||
          e.toString().contains('HandshakeException') ||
          e.toString().contains('Connection refused')) {
        print('🌐 Network error detected - server might be down');
      }

      // Fallback to local storage
      final fallbackCustomers = await UserStorageService.getCustomers();
      print(
          '📦 Loaded ${fallbackCustomers.length} customers from local storage as fallback');
      return fallbackCustomers;
    }
  }

  /// Create a new customer via API
  Future<Customer> createCustomerViaApi(Customer customer) async {
    try {
      print('🔄 Creating customer via API: ${customer.name}');
      final customerData = _convertCustomerToApiUser(customer);
      print('📤 Request data: $customerData');
      final response = await _adminApiService.createCustomer(customerData);
      print('📥 Response status: ${response.statusCode}');
      print('📄 Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final apiCustomer = response.data;
        final createdCustomer = _convertApiUserToCustomer(apiCustomer);

        // Add to local storage
        await UserStorageService.addCustomer(createdCustomer);
        return createdCustomer;
      } else {
        throw Exception('Failed to create customer: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ Error creating customer via API: $e');
      print('Stack trace: $stackTrace');
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

  /// Activate/Deactivate customer via API (Users API v1)
  Future<Customer> toggleCustomerStatusViaApi(
      String customerId, bool activate) async {
    try {
      final response = activate
          ? await _adminApiService.restoreUser(customerId)
          : await _adminApiService.softDeleteUser(customerId);

      if (response.statusCode == 200) {
        // Swagger shows text/plain with wrapper; response body may
        // not contain the full user object. Update local state directly.
        final customers = await UserStorageService.getCustomers();
        final customer = customers.firstWhere((c) => c.id == customerId,
            orElse: () => Customer(
                  id: customerId,
                  name: '',
                  email: '',
                  phone: '',
                  address: '',
                  dateOfBirth:
                      DateTime.now().subtract(const Duration(days: 365 * 25)),
                  gender: 'Nam',
                  occupation: '',
                  notes: '',
                  createdAt: DateTime.now(),
                ));
        final updatedCustomer = customer.copyWith(isActive: activate);
        await UserStorageService.updateCustomer(updatedCustomer);
        return updatedCustomer;
      } else {
        throw Exception(
            'Failed to ${activate ? 'restore' : 'soft delete'} customer: ${response.statusCode}');
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

