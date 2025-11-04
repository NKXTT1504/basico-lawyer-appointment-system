import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_colors.dart';
// AppBar is managed globally in MainNavigation for mobile
import '../../data/services/user_storage_service.dart';
import '../../data/services/customer_api_service.dart';
import '../../data/models/customer.dart';
import '../../data/models/admin_user.dart';
import '../../data/services/admin_api_service.dart'; // Added import for AdminApiService

class AdminCustomersPage extends StatefulWidget {
  const AdminCustomersPage({super.key});

  @override
  State<AdminCustomersPage> createState() => _AdminCustomersPageState();
}

class _AdminCustomersPageState extends State<AdminCustomersPage> {
  late final CustomerApiService _customerApiService;
  List<Customer> _customers = [];
  List<Customer> _filteredCustomers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedGender = 'all';
  String _selectedOccupation = 'all';

  @override
  void initState() {
    super.initState();
    _customerApiService = GetIt.instance<CustomerApiService>();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    try {
      final current = await UserStorageService.getCurrentUser();
      if (current == null || current.role != UserRole.admin) {
        if (mounted)
          context.go(
              current?.role == UserRole.lawyer ? '/lawyer/dashboard' : '/home');
        return;
      }

      // Fetch customers from API (which will also sync to local storage)
      print('🔄 Loading customers via API...');
      final customers = await _customerApiService.fetchCustomersFromApi();
      print('📦 Loaded ${customers.length} customers from API');

      setState(() {
        _customers = customers;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('❌ Error loading customers: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Có lỗi xảy ra khi tải dữ liệu: $e');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredCustomers = _customers.where((customer) {
        // Search filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          if (!customer.name.toLowerCase().contains(query) &&
              !customer.email.toLowerCase().contains(query) &&
              !customer.phone.toLowerCase().contains(query) &&
              !customer.occupation.toLowerCase().contains(query)) {
            return false;
          }
        }

        // Gender filter
        if (_selectedGender != 'all' && customer.gender != _selectedGender) {
          return false;
        }

        // Occupation filter
        if (_selectedOccupation != 'all' &&
            customer.occupation != _selectedOccupation) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _toggleActive(Customer customer) async {
    try {
      final updated = await _customerApiService.toggleCustomerStatusViaApi(
          customer.id, !customer.isActive);
      setState(() {
        final idx = _customers.indexWhere((c) => c.id == customer.id);
        if (idx != -1) _customers[idx] = updated;
        _applyFilters();
      });
      _showSuccessSnackBar(
          updated.isActive ? 'Đã bật hoạt động' : 'Đã tắt hoạt động');
    } catch (e) {
      _showErrorSnackBar('Lỗi cập nhật trạng thái: $e');
    }
  }

  void _showAddCustomerDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          title: const Text(
            'Thêm khách hàng mới',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Họ và tên',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Số điện thoại',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate input
                final validationResult = _validateCustomerInput(
                  nameController.text,
                  emailController.text,
                  phoneController.text,
                  passwordController.text,
                );

                if (validationResult.isNotEmpty) {
                  _showErrorSnackBar(validationResult);
                  return;
                }

                try {
                  // Check if email already exists
                  final existingCustomers =
                      await UserStorageService.getCustomers();
                  if (existingCustomers.any((customer) =>
                      customer.email.toLowerCase() ==
                      emailController.text.toLowerCase())) {
                    _showErrorSnackBar('Email đã tồn tại trong hệ thống');
                    return;
                  }

                  final newCustomer = Customer(
                    id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text.trim(),
                    email: emailController.text.trim().toLowerCase(),
                    phone: phoneController.text.trim(),
                    address: '',
                    dateOfBirth:
                        DateTime.now().subtract(const Duration(days: 365 * 25)),
                    gender: 'Không xác định',
                    occupation: 'Không xác định',
                    notes: '',
                    createdAt: DateTime.now(),
                  );

                  await UserStorageService.addCustomer(newCustomer);
                  // Best-effort: create backend user (Users API)
                  try {
                    await AdminApiService().createUser({
                      'fullName': newCustomer.name,
                      'email': newCustomer.email,
                      'password': passwordController.text,
                      'phoneNumber': newCustomer.phone,
                      'role': 'Customer',
                      'isActive': true,
                    });
                  } catch (_) {}
                  await _loadCustomers();
                  Navigator.pop(context);
                  _showSuccessSnackBar('Thêm khách hàng thành công');
                } catch (e) {
                  _showErrorSnackBar('Có lỗi xảy ra khi thêm khách hàng: $e');
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(96, 44)),
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCustomerDialog(Customer customer) {
    final nameController = TextEditingController(text: customer.name);
    final emailController = TextEditingController(text: customer.email);
    final phoneController = TextEditingController(text: customer.phone);
    final originalEmail = customer.email;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          title: const Text('Chỉnh sửa khách hàng',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                        labelText: 'Họ và tên',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 16),
                TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 16),
                TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                        labelText: 'Số điện thoại',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)))),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                try {
                  final updated = customer.copyWith(
                    name: nameController.text.trim(),
                    email: emailController.text.trim().toLowerCase(),
                    phone: phoneController.text.trim(),
                    updatedAt: DateTime.now(),
                  );
                  await UserStorageService.updateCustomer(updated);
                  await UserStorageService.syncCustomerUserAccount(
                    oldEmail: originalEmail,
                    name: updated.name,
                    newEmail: updated.email,
                  );
                  await _loadCustomers();
                  if (mounted) Navigator.pop(context);
                  _showSuccessSnackBar('Cập nhật khách hàng thành công');
                } catch (e) {
                  _showErrorSnackBar('Lỗi khi cập nhật: $e');
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      body: Column(
        children: [
          // Search
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Search bar
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _applyFilters();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên, email, số điện thoại...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _applyFilters();
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),
              ],
            ),
          ),

          // Customers list
          Expanded(
            child: _filteredCustomers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person,
                          size: isMobile ? 48 : 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _customers.isEmpty
                              ? 'Chưa có khách hàng nào'
                              : 'Không tìm thấy khách hàng phù hợp',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(isMobile ? 12 : 16),
                    itemCount: _filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = _filteredCustomers[index];
                      return _buildCustomerCard(customer);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCustomerDialog,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            LayoutBuilder(builder: (context, c) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    radius: isMobile ? 20 : 24,
                    child: Text(
                      customer.name[0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 16 : 18,
                      ),
                    ),
                  ),
                  SizedBox(width: isMobile ? 8 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: TextStyle(
                            fontSize: isMobile ? 15 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          customer.occupation,
                          style: TextStyle(
                            fontSize: isMobile ? 13 : 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 6 : 8,
                        vertical: isMobile ? 3 : 4),
                    decoration: BoxDecoration(
                      color: customer.isActive ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      customer.isActive ? 'Hoạt động' : 'Không hoạt động',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 10 : 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            }),

            SizedBox(height: isMobile ? 12 : 16),

            // Details (only fields available from backend: email & phone)
            _buildDetailRow(Icons.email, 'Email', customer.email),
            _buildDetailRow(Icons.phone, 'Số điện thoại', customer.phone),

            SizedBox(height: isMobile ? 12 : 16),

            // Actions (no delete; toggle active instead)
            if (isMobile) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showEditCustomerDialog(customer),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Chỉnh sửa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _toggleActive(customer),
                  icon: Icon(
                    customer.isActive ? Icons.visibility_off : Icons.visibility,
                    color:
                        customer.isActive ? AppColors.error : AppColors.success,
                  ),
                  label: Text(
                    customer.isActive ? 'Tắt hoạt động' : 'Bật hoạt động',
                    style: TextStyle(
                      color: customer.isActive
                          ? AppColors.error
                          : AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: customer.isActive
                            ? AppColors.error
                            : AppColors.success),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showEditCustomerDialog(customer),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Chỉnh sửa'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _toggleActive(customer),
                      icon: Icon(
                        customer.isActive
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: customer.isActive
                            ? AppColors.error
                            : AppColors.success,
                      ),
                      label: Text(
                        customer.isActive ? 'Tắt hoạt động' : 'Bật hoạt động',
                        style: TextStyle(
                          color: customer.isActive
                              ? AppColors.error
                              : AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: customer.isActive
                                ? AppColors.error
                                : AppColors.success),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: isMobile ? 14 : 16, color: Colors.grey[600]),
          SizedBox(width: isMobile ? 6 : 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontSize: isMobile ? 13 : 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isMobile ? 13 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _validateCustomerInput(
      String name, String email, String phone, String password) {
    if (name.trim().isEmpty) return 'Vui lòng nhập họ và tên';
    if (name.trim().length < 2) return 'Họ và tên phải có ít nhất 2 ký tự';
    if (email.trim().isEmpty) return 'Vui lòng nhập email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$').hasMatch(email.trim())) {
      return 'Email không hợp lệ';
    }
    if (password.trim().isEmpty || password.trim().length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    if (phone.trim().isEmpty) return 'Vui lòng nhập số điện thoại';
    if (!RegExp(r'^[0-9]{10,11}\$').hasMatch(phone.trim())) {
      return 'Số điện thoại phải có 10-11 chữ số';
    }
    return '';
  }

  // Filters removed to match backend fields
}
