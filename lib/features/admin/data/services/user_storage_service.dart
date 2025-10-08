import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
    final users = await getUsers();
    try {
      final normalizedEmail = email.trim().toLowerCase();
      return users.firstWhere(
        (user) =>
            user.email.toLowerCase() == normalizedEmail &&
            user.password == password &&
            user.isActive,
      );
    } catch (e) {
      return null;
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

  // Initialize sample data
  static Future<void> initializeSampleData() async {
    // Check if data already exists
    final existingUsers = await getUsers();
    if (existingUsers.isNotEmpty) return;

    // Create default users (no default lawyer account; admins create lawyer accounts)
    final users = [
      User(
        id: 'user_admin_001',
        email: 'admin@basico.com',
        password: 'admin123',
        name: 'Administrator',
        role: UserRole.admin,
        createdAt: DateTime.now(),
      ),
      User(
        id: 'user_customer_001',
        email: 'customer@basico.com',
        password: 'customer123',
        name: 'Khách hàng Lê Văn B',
        role: UserRole.customer,
        createdAt: DateTime.now(),
      ),
    ];
    for (final user in users) {
      await addUser(user);
    }

    // Create sample employees
    final employees = [
      Employee(
        id: 'emp_001',
        name: 'Nguyễn Văn A',
        email: 'nguyenvana@basico.com',
        phone: '0123456789',
        position: 'Receptionist',
        department: 'Front Office',
        hireDate: DateTime(2023, 1, 15),
        salary: 8000000,
        address: '123 Đường ABC, Quận 1, TP.HCM',
        createdAt: DateTime.now(),
      ),
      Employee(
        id: 'emp_002',
        name: 'Trần Thị B',
        email: 'tranthib@basico.com',
        phone: '0987654321',
        position: 'HR Manager',
        department: 'Human Resources',
        hireDate: DateTime(2022, 6, 1),
        salary: 12000000,
        address: '456 Đường XYZ, Quận 2, TP.HCM',
        createdAt: DateTime.now(),
      ),
    ];
    for (final employee in employees) {
      await addEmployee(employee);
    }

    // Seed 10 customers
    for (int i = 1; i <= 10; i++) {
      final cust = Customer(
        id: 'cust_${i.toString().padLeft(3, '0')}',
        name: 'Khách hàng ${i.toString().padLeft(2, '0')}',
        email: 'customer${i}@basico.com',
        phone: '0900000${(100 + i).toString()}',
        address: 'Số ${i}, Quận ${i % 12 + 1}, TP.HCM',
        dateOfBirth: DateTime(1990 + (i % 10), (i % 12) + 1, (i % 27) + 1),
        gender: i % 2 == 0 ? 'Nam' : 'Nữ',
        occupation: i % 2 == 0 ? 'Kỹ sư' : 'Nhân viên',
        createdAt: DateTime.now(),
      );
      await addCustomer(cust);
      // Also create login user for customer i
      await addUser(User(
        id: 'user_customer_${i.toString().padLeft(3, '0')}',
        email: 'customer${i}@basico.com',
        password: '123456',
        name: 'Khách hàng ${i.toString().padLeft(2, '0')}',
        role: UserRole.customer,
        createdAt: DateTime.now(),
      ));
    }

    // Seed 10 lawyers + login accounts
    final specs = [
      'Luật Dân sự',
      'Luật Hình sự',
      'Luật Doanh nghiệp',
      'Hôn nhân & Gia đình',
      'Sở hữu trí tuệ',
      'Lao động',
      'Đất đai',
      'Thuế',
      'Hợp đồng',
      'Tố tụng'
    ];
    for (int i = 1; i <= 10; i++) {
      final law = Lawyer(
        id: 'law_${i.toString().padLeft(3, '0')}',
        name: 'Luật sư ${i.toString().padLeft(2, '0')}',
        email: 'lawyer${i}@basico.com',
        phone: '0777000${(100 + i).toString()}',
        address: 'Văn phòng ${i}, TP.HCM',
        specialization: specs[i - 1],
        licenseNumber: 'LS${(100000 + i).toString()}',
        experienceYears: 3 + (i % 12),
        hourlyRate: 400000 + (i * 20000),
        baseSalary: 12000000 + (i * 500000),
        commissionRate: 0.1 + (i % 5) * 0.01,
        successRate: 0.7 + (i % 10) * 0.01,
        ongoingCases: i % 3,
        bio: 'Luật sư chuyên môn ${specs[i - 1]} với kinh nghiệm thực tiễn.',
        languages: ['Tiếng Việt', if (i % 2 == 0) 'Tiếng Anh'],
        certifications: ['Chứng chỉ luật sư'],
        createdAt: DateTime.now(),
      );
      await addLawyer(law);
      await addUser(User(
        id: 'user_lawyer_${i.toString().padLeft(3, '0')}',
        email: 'lawyer${i}@basico.com',
        password: '123456',
        name: law.name,
        role: UserRole.lawyer,
        createdAt: DateTime.now(),
      ));
    }

    // Seed sample appointments across months if none exist
    final existingApts = await getAppointments();
    if (existingApts.isEmpty) {
      final now = DateTime.now();
      final year = now.year;
      final months = <int>[6, 7, 8, 9, 10];
      final slots = <String>[
        '09:00 - 10:00',
        '10:00 - 11:00',
        '14:00 - 15:00',
        '15:00 - 16:00'
      ];
      int idCounter = 1000;
      int custIdx = 1;
      int lawIdx = 1;
      for (final m in months) {
        for (int d = 3; d <= 21; d += 6) {
          // round robin pick
          final custId = 'cust_${custIdx.toString().padLeft(3, '0')}';
          final lawId = 'law_${lawIdx.toString().padLeft(3, '0')}';
          final custs = await getCustomers();
          final laws = await getLawyers();
          final cust = custs.firstWhere((c) => c.id == custId,
              orElse: () => custs.first);
          final law =
              laws.firstWhere((l) => l.id == lawId, orElse: () => laws.first);
          final day = DateTime(year, m, d, 9);
          for (int s = 0; s < slots.length; s++) {
            final status = (s % 4 == 0)
                ? AppointmentStatus.completed
                : (s % 4 == 1)
                    ? AppointmentStatus.confirmed
                    : (s % 4 == 2)
                        ? AppointmentStatus.pending
                        : AppointmentStatus.cancelled;
            final apt = Appointment(
              id: 'apt_${idCounter++}',
              customerId: cust.id,
              customerName: cust.name,
              lawyerId: law.id,
              lawyerName: law.name,
              appointmentDate: DateTime(year, m, d),
              timeSlot: slots[s],
              duration: slots[s].contains('10:00 - 11:00') ? '1 giờ' : '1 giờ',
              type: law.specialization,
              description: 'Lịch mẫu tháng $m',
              status: status,
              notes: '',
              fee: status == AppointmentStatus.completed
                  ? (400000 + (s * 50000)).toDouble()
                  : 0,
              createdAt: day.subtract(const Duration(days: 2)),
              updatedAt: day,
            );
            await addAppointment(apt);
          }
          custIdx = custIdx % 10 + 1;
          lawIdx = lawIdx % 10 + 1;
        }
      }
    }
  }
}
