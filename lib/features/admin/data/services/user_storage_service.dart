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

    // Create sample customers
    final customers = [
      Customer(
        id: 'cust_001',
        name: 'Lê Văn C',
        email: 'levanc@gmail.com',
        phone: '0111222333',
        address: '789 Đường DEF, Quận 3, TP.HCM',
        dateOfBirth: DateTime(1985, 3, 15),
        gender: 'Nam',
        occupation: 'Kỹ sư',
        notes: 'Khách hàng VIP',
        createdAt: DateTime.now(),
      ),
      Customer(
        id: 'cust_002',
        name: 'Phạm Thị D',
        email: 'phamthid@gmail.com',
        phone: '0444555666',
        address: '321 Đường GHI, Quận 4, TP.HCM',
        dateOfBirth: DateTime(1990, 7, 22),
        gender: 'Nữ',
        occupation: 'Giáo viên',
        createdAt: DateTime.now(),
      ),
    ];
    for (final customer in customers) {
      await addCustomer(customer);
    }

    // Create sample lawyers
    final lawyers = [
      Lawyer(
        id: 'law_001',
        name: 'Luật sư Nguyễn Văn E',
        email: 'luatsue@basico.com',
        phone: '0777888999',
        address: '555 Đường JKL, Quận 5, TP.HCM',
        specialization: 'Luật Dân sự',
        licenseNumber: 'LS001234',
        experienceYears: 8,
        hourlyRate: 500000,
        baseSalary: 15000000,
        commissionRate: 0.12,
        successRate: 0.78,
        ongoingCases: 1,
        bio: 'Chuyên gia về luật dân sự với 8 năm kinh nghiệm',
        languages: ['Tiếng Việt', 'Tiếng Anh'],
        certifications: ['Chứng chỉ luật sư', 'Chứng chỉ quốc tế'],
        createdAt: DateTime.now(),
      ),
      Lawyer(
        id: 'law_002',
        name: 'Luật sư Trần Thị F',
        email: 'luatsuf@basico.com',
        phone: '0333444555',
        address: '999 Đường MNO, Quận 6, TP.HCM',
        specialization: 'Luật Hình sự',
        licenseNumber: 'LS005678',
        experienceYears: 12,
        hourlyRate: 700000,
        baseSalary: 22000000,
        commissionRate: 0.15,
        successRate: 0.85,
        ongoingCases: 2,
        bio: 'Chuyên gia về luật hình sự với 12 năm kinh nghiệm',
        languages: ['Tiếng Việt', 'Tiếng Anh', 'Tiếng Pháp'],
        certifications: [
          'Chứng chỉ luật sư',
          'Chứng chỉ quốc tế',
          'Chứng chỉ đặc biệt'
        ],
        createdAt: DateTime.now(),
      ),
    ];
    for (final lawyer in lawyers) {
      await addLawyer(lawyer);
    }

    // Create sample appointments
    final appointments = [
      Appointment(
        id: 'apt_001',
        customerId: 'cust_001',
        customerName: 'Lê Văn C',
        lawyerId: 'law_001',
        lawyerName: 'Luật sư Nguyễn Văn E',
        appointmentDate: DateTime.now().add(const Duration(days: 1)),
        timeSlot: '09:00 - 10:00',
        duration: '1 giờ',
        type: 'Tư vấn pháp lý',
        description: 'Tư vấn về hợp đồng lao động',
        status: AppointmentStatus.confirmed,
        notes: 'Khách hàng cần tư vấn về quyền lợi lao động',
        fee: 500000,
        createdAt: DateTime.now(),
      ),
      Appointment(
        id: 'apt_002',
        customerId: 'cust_002',
        customerName: 'Phạm Thị D',
        lawyerId: 'law_002',
        lawyerName: 'Luật sư Trần Thị F',
        appointmentDate: DateTime.now().add(const Duration(days: 3)),
        timeSlot: '14:00 - 15:30',
        duration: '1.5 giờ',
        type: 'Tư vấn pháp lý',
        description: 'Tư vấn về ly hôn',
        status: AppointmentStatus.pending,
        notes: 'Khách hàng cần tư vấn về thủ tục ly hôn',
        fee: 1050000,
        createdAt: DateTime.now(),
      ),
    ];
    for (final appointment in appointments) {
      await addAppointment(appointment);
    }
  }
}
