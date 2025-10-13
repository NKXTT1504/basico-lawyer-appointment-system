import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/admin_user.dart';
import '../models/employee.dart';
import '../models/customer.dart';
import '../models/lawyer.dart';
import '../models/appointment.dart';

class UserStorageService {
  static const String _usersKey = 'users';
  static const String _employeesKey = 'employees';
  static const String _customersKey = 'customers';
  static const String _lawyersKey = 'lawyers';
  static const String _appointmentsKey = 'appointments';
  static const String _currentUserKey = 'current_user';

  // Users Management
  static Future<List<User>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_usersKey);
    if (data == null) return [];

    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((json) => User.fromJson(json)).toList();
  }

  static Future<void> saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final String data =
        json.encode(users.map((user) => user.toJson()).toList());
    await prefs.setString(_usersKey, data);
  }

  static Future<void> addUser(User user) async {
    final users = await getUsers();
    users.add(user);
    await saveUsers(users);
  }

  static Future<User?> getUserByEmail(String email) async {
    final users = await getUsers();
    try {
      return users.firstWhere(
        (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_currentUserKey);
    if (data == null) return null;
    return User.fromJson(json.decode(data));
  }

  // Session helpers
  static Future<bool> isLoggedIn() async {
    final current = await getCurrentUser();
    return current != null && current.isActive;
  }

  static Future<UserRole?> getCurrentUserRole() async {
    final current = await getCurrentUser();
    return current?.role;
  }

  static Future<Customer?> getCurrentCustomerProfile() async {
    final current = await getCurrentUser();
    if (current == null) return null;
    final customers = await getCustomers();
    try {
      return customers.firstWhere(
          (c) => c.email.toLowerCase() == current.email.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  /// Profile is considered complete if these fields are non-empty and valid
  /// Adjust the rules as the business requires
  static Future<bool> isProfileCompleteForCurrentUser() async {
    final role = await getCurrentUserRole();
    if (role != UserRole.customer) return true; // only enforce for customers
    final profile = await getCurrentCustomerProfile();
    if (profile == null) return false;
    final bool hasBasics =
        profile.name.trim().isNotEmpty && profile.email.trim().isNotEmpty;
    final bool hasContact = profile.phone.trim().isNotEmpty;
    // Address is currently not editable in the profile form, so don't block on it
    return hasBasics && hasContact && profile.isActive;
  }

  static Future<void> setCurrentUser(User? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      await prefs.remove(_currentUserKey);
    } else {
      await prefs.setString(_currentUserKey, json.encode(user.toJson()));
    }
  }

  static Future<User?> loginUser(String email, String password) async {
    // Call backend API: POST /api/mobile/login
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: AppConstants.baseUrl,
          connectTimeout: AppConstants.apiTimeout,
          receiveTimeout: AppConstants.apiTimeout,
        ),
      );

      final response = await dio.post(
        '/api/auth/login',
        data: {
          // Match Users.Services.API LoginRequestDTO
          'Email': email.trim(),
          'Password': password,
        },
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }),
      );

      final Map<String, dynamic> body =
          response.data is String ? json.decode(response.data) : response.data;

      // Users service format: { isSuccess, message, token, user }
      final bool success = body['isSuccess'] == true;
      if (!success) return null;

      final String? token = body['token'] as String?;
      final Map<String, dynamic> backendUser =
          body['user'] is Map<String, dynamic>
              ? Map<String, dynamic>.from(body['user'] as Map<String, dynamic>)
              : <String, dynamic>{};

      final String roleStr = (backendUser['role'] ?? backendUser['Role'] ?? '')
          .toString()
          .toLowerCase();
      UserRole role = UserRole.customer;
      if (roleStr == 'admin') role = UserRole.admin;
      if (roleStr == 'lawyer') role = UserRole.lawyer;

      final user = User(
        id: (backendUser['id'] ?? backendUser['Id'] ?? '').toString(),
        email:
            (backendUser['email'] ?? backendUser['Email'] ?? email).toString(),
        // Keep the entered password locally only for compatibility with existing model
        password: password,
        name: (backendUser['fullName'] ??
                backendUser['FullName'] ??
                backendUser['name'] ??
                '')
            .toString(),
        role: role,
        createdAt: DateTime.now(),
      );

      // Persist token and session
      final prefs = await SharedPreferences.getInstance();
      if (token != null && token.isNotEmpty) {
        await prefs.setString(AppConstants.tokenKey, token);
      }
      await setCurrentUser(user);
      return user;
    } on DioException catch (e) {
      // Extract server message for better UX
      try {
        final data = e.response?.data;
        final Map<String, dynamic> body = data is String
            ? json.decode(data)
            : (data as Map<String, dynamic>? ?? {});
        final String message =
            (body['message'] ?? body['Message'] ?? 'Đăng nhập thất bại')
                .toString();
        throw Exception(message);
      } catch (_) {
        throw Exception('Đăng nhập thất bại');
      }
    } catch (e) {
      throw Exception('Đăng nhập thất bại');
    }
  }

  // Employees Management
  static Future<List<Employee>> getEmployees() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_employeesKey);
    if (data == null) return [];

    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((json) => Employee.fromJson(json)).toList();
  }

  static Future<void> saveEmployees(List<Employee> employees) async {
    final prefs = await SharedPreferences.getInstance();
    final String data =
        json.encode(employees.map((emp) => emp.toJson()).toList());
    await prefs.setString(_employeesKey, data);
  }

  static Future<void> addEmployee(Employee employee) async {
    final employees = await getEmployees();
    employees.add(employee);
    await saveEmployees(employees);
  }

  static Future<void> updateEmployee(Employee employee) async {
    final employees = await getEmployees();
    final index = employees.indexWhere((emp) => emp.id == employee.id);
    if (index != -1) {
      employees[index] = employee;
      await saveEmployees(employees);
    }
  }

  static Future<void> deleteEmployee(String id) async {
    final employees = await getEmployees();
    employees.removeWhere((emp) => emp.id == id);
    await saveEmployees(employees);
  }

  // Customers Management
  static Future<List<Customer>> getCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_customersKey);
    if (data == null) return [];

    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((json) => Customer.fromJson(json)).toList();
  }

  static Future<void> saveCustomers(List<Customer> customers) async {
    final prefs = await SharedPreferences.getInstance();
    final String data =
        json.encode(customers.map((customer) => customer.toJson()).toList());
    await prefs.setString(_customersKey, data);
  }

  static Future<void> addCustomer(Customer customer) async {
    final customers = await getCustomers();
    customers.add(customer);
    await saveCustomers(customers);
  }

  static Future<void> updateCustomer(Customer customer) async {
    final customers = await getCustomers();
    final index = customers.indexWhere((cust) => cust.id == customer.id);
    if (index != -1) {
      customers[index] = customer;
      await saveCustomers(customers);
    }
  }

  static Future<void> deleteCustomer(String id) async {
    final customers = await getCustomers();
    customers.removeWhere((cust) => cust.id == id);
    await saveCustomers(customers);
  }

  // Lawyers Management
  static Future<List<Lawyer>> getLawyers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_lawyersKey);
    if (data == null) return [];

    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((json) => Lawyer.fromJson(json)).toList();
  }

  static Future<void> saveLawyers(List<Lawyer> lawyers) async {
    final prefs = await SharedPreferences.getInstance();
    final String data =
        json.encode(lawyers.map((lawyer) => lawyer.toJson()).toList());
    await prefs.setString(_lawyersKey, data);
  }

  static Future<void> addLawyer(Lawyer lawyer) async {
    final lawyers = await getLawyers();
    lawyers.add(lawyer);
    await saveLawyers(lawyers);
  }

  static Future<void> updateLawyer(Lawyer lawyer) async {
    final lawyers = await getLawyers();
    final index = lawyers.indexWhere((law) => law.id == lawyer.id);
    if (index != -1) {
      lawyers[index] = lawyer;
      await saveLawyers(lawyers);

      // Basic best-effort sync by matching current lawyer email
      final users = await getUsers();
      final int userIdxByEmail = users.indexWhere(
          (u) => u.email.toLowerCase() == lawyer.email.toLowerCase());
      if (userIdxByEmail != -1) {
        users[userIdxByEmail] =
            users[userIdxByEmail].copyWith(name: lawyer.name);
        await saveUsers(users);
      }
    }
  }

  static Future<void> deleteLawyer(String id) async {
    final lawyers = await getLawyers();
    Lawyer? removed;
    lawyers.removeWhere((law) {
      final match = law.id == id;
      if (match) removed = law;
      return match;
    });
    await saveLawyers(lawyers);

    // Remove associated user account
    final users = await getUsers();
    users.removeWhere((u) =>
        u.id == 'user_$id' || (removed != null && u.email == removed!.email));
    await saveUsers(users);
  }

  // Update user's password by email (used by admin to reset lawyer password)
  static Future<void> updateUserPasswordByEmail(
      String email, String newPassword) async {
    final users = await getUsers();
    final idx = users
        .indexWhere((u) => u.email.toLowerCase() == email.trim().toLowerCase());
    if (idx != -1) {
      users[idx] = users[idx].copyWith(password: newPassword);
      await saveUsers(users);
    }
  }

  // Sync customer's associated user account when admin edits customer info
  static Future<void> syncCustomerUserAccount({
    required String oldEmail,
    required String name,
    required String newEmail,
  }) async {
    final users = await getUsers();
    int idx = users.indexWhere(
        (u) => u.email.toLowerCase() == oldEmail.trim().toLowerCase());
    if (idx == -1) {
      idx = users.indexWhere(
          (u) => u.email.toLowerCase() == newEmail.trim().toLowerCase());
    }
    if (idx != -1) {
      users[idx] =
          users[idx].copyWith(name: name, email: newEmail.trim().toLowerCase());
      await saveUsers(users);
    }
  }

  // Sync lawyer's associated user account when admin edits lawyer info.
  // If a user with oldEmail exists, update name/email and optionally password.
  // If not found but a user with newEmail exists, update name/password there.
  static Future<void> syncLawyerUserAccount({
    required String oldEmail,
    required String name,
    required String newEmail,
    String? newPassword,
  }) async {
    final users = await getUsers();
    int idx = users.indexWhere(
        (u) => u.email.toLowerCase() == oldEmail.trim().toLowerCase());
    if (idx == -1) {
      idx = users.indexWhere(
          (u) => u.email.toLowerCase() == newEmail.trim().toLowerCase());
    }
    if (idx != -1) {
      var updated = users[idx].copyWith(name: name, email: newEmail.trim());
      if (newPassword != null && newPassword.isNotEmpty) {
        updated = updated.copyWith(password: newPassword);
      }
      users[idx] = updated;
      await saveUsers(users);
    } else {
      // No existing user found for this lawyer profile. If a new password is
      // provided, create a new login account for the lawyer.
      if (newPassword != null && newPassword.isNotEmpty) {
        final newUser = User(
          id: 'user_lawyer_${DateTime.now().millisecondsSinceEpoch}',
          email: newEmail.trim().toLowerCase(),
          password: newPassword,
          name: name,
          role: UserRole.lawyer,
          createdAt: DateTime.now(),
        );
        await addUser(newUser);
      }
    }
  }

  // Appointments Management
  static Future<List<Appointment>> getAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_appointmentsKey);
    if (data == null) return [];

    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((json) => Appointment.fromJson(json)).toList();
  }

  static Future<void> saveAppointments(List<Appointment> appointments) async {
    final prefs = await SharedPreferences.getInstance();
    final String data =
        json.encode(appointments.map((apt) => apt.toJson()).toList());
    await prefs.setString(_appointmentsKey, data);
  }

  static Future<void> addAppointment(Appointment appointment) async {
    final appointments = await getAppointments();
    appointments.add(appointment);
    await saveAppointments(appointments);
  }

  static Future<void> updateAppointment(Appointment appointment) async {
    final appointments = await getAppointments();
    final index = appointments.indexWhere((apt) => apt.id == appointment.id);
    if (index != -1) {
      appointments[index] = appointment;
      await saveAppointments(appointments);
    }
  }

  static Future<void> deleteAppointment(String id) async {
    final appointments = await getAppointments();
    appointments.removeWhere((apt) => apt.id == id);
    await saveAppointments(appointments);
  }

  // Get appointments for specific lawyer
  static Future<List<Appointment>> getLawyerAppointments(
      String lawyerId) async {
    final appointments = await getAppointments();
    return appointments.where((apt) => apt.lawyerId == lawyerId).toList();
  }

  // Initialize sample data (removed): clear old mock data and return
  static Future<void> initializeSampleData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
    await prefs.remove(_employeesKey);
    await prefs.remove(_customersKey);
    await prefs.remove(_lawyersKey);
    await prefs.remove(_appointmentsKey);
    // No local seeding; data should come from backend APIs
  }
}
