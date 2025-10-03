import 'package:flutter/material.dart';
// AppBar is managed globally in MainNavigation for mobile
import '../../data/services/user_storage_service.dart';
import '../../data/models/lawyer.dart';
import '../../data/models/admin_user.dart';

class AdminLawyersPage extends StatefulWidget {
  const AdminLawyersPage({super.key});

  @override
  State<AdminLawyersPage> createState() => _AdminLawyersPageState();
}

class _AdminLawyersPageState extends State<AdminLawyersPage> {
  List<Lawyer> _lawyers = [];
  List<Lawyer> _filteredLawyers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedSpecialization = 'all';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadLawyers();
  }

  Future<void> _loadLawyers() async {
    try {
      final lawyers = await UserStorageService.getLawyers();
      setState(() {
        _lawyers = lawyers;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Có lỗi xảy ra: $e');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredLawyers = _lawyers.where((lawyer) {
        // Search filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          if (!lawyer.name.toLowerCase().contains(query) &&
              !lawyer.email.toLowerCase().contains(query) &&
              !lawyer.specialization.toLowerCase().contains(query) &&
              !lawyer.phone.toLowerCase().contains(query)) {
            return false;
          }
        }

        // Specialization filter
        if (_selectedSpecialization != 'all' &&
            lawyer.specialization != _selectedSpecialization) {
          return false;
        }

        // Status filter
        if (_selectedStatus != 'all') {
          if (_selectedStatus == 'active' && !lawyer.isActive) {
            return false;
          }
          if (_selectedStatus == 'inactive' && lawyer.isActive) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _deleteLawyer(String id) async {
    try {
      await UserStorageService.deleteLawyer(id);
      await _loadLawyers();
      _showSuccessSnackBar('Xóa luật sư thành công');
    } catch (e) {
      _showErrorSnackBar('Có lỗi xảy ra: $e');
    }
  }

  void _showDeleteDialog(Lawyer lawyer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa luật sư ${lawyer.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteLawyer(lawyer.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showAddLawyerDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final specializationController = TextEditingController();
    final licenseNumberController = TextEditingController();
    final experienceController = TextEditingController();
    final hourlyRateController = TextEditingController();
    final baseSalaryController = TextEditingController();
    final commissionController = TextEditingController(text: '0.10');
    final successRateController = TextEditingController(text: '0.70');
    final bioController = TextEditingController();
    final languagesController = TextEditingController();
    final certificationsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm luật sư mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: specializationController,
                decoration: const InputDecoration(
                  labelText: 'Chuyên môn',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: licenseNumberController,
                decoration: const InputDecoration(
                  labelText: 'Số chứng chỉ hành nghề',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: experienceController,
                decoration: const InputDecoration(
                  labelText: 'Số năm kinh nghiệm',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: hourlyRateController,
                decoration: const InputDecoration(
                  labelText: 'Phí tư vấn/giờ (VNĐ)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: baseSalaryController,
                decoration: const InputDecoration(
                  labelText: 'Lương cứng/tháng (VNĐ)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commissionController,
                      decoration: const InputDecoration(
                        labelText: 'Hoa hồng (%)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: successRateController,
                      decoration: const InputDecoration(
                        labelText: 'Tỉ lệ thành công (%)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(
                  labelText: 'Tiểu sử',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: languagesController,
                decoration: const InputDecoration(
                  labelText: 'Ngôn ngữ (cách nhau bởi dấu phẩy)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: certificationsController,
                decoration: const InputDecoration(
                  labelText: 'Chứng chỉ (cách nhau bởi dấu phẩy)',
                  border: OutlineInputBorder(),
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
              final validationResult = _validateLawyerInput(
                nameController.text,
                emailController.text,
                passwordController.text,
                phoneController.text,
                addressController.text,
                specializationController.text,
                licenseNumberController.text,
                experienceController.text,
                hourlyRateController.text,
              );

              if (validationResult.isNotEmpty) {
                _showErrorSnackBar(validationResult);
                return;
              }

              try {
                // Check if email already exists
                final existingUsers = await UserStorageService.getUsers();
                if (existingUsers.any((user) =>
                    user.email.toLowerCase() ==
                    emailController.text.trim().toLowerCase())) {
                  _showErrorSnackBar('Email đã tồn tại trong hệ thống');
                  return;
                }

                // Check if license number already exists
                final existingLawyers = await UserStorageService.getLawyers();
                if (existingLawyers.any((lawyer) =>
                    lawyer.licenseNumber ==
                    licenseNumberController.text.trim())) {
                  _showErrorSnackBar('Số chứng chỉ hành nghề đã tồn tại');
                  return;
                }

                final languages = languagesController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();

                final certifications = certificationsController.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();

                // Create lawyer user account
                final lawyerUser = User(
                  id: 'user_lawyer_${DateTime.now().millisecondsSinceEpoch}',
                  email: emailController.text.trim().toLowerCase(),
                  password: passwordController.text,
                  name: nameController.text.trim(),
                  role: UserRole.lawyer,
                  createdAt: DateTime.now(),
                );

                // Create lawyer profile
                final newLawyer = Lawyer(
                  id: 'law_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameController.text.trim(),
                  email: emailController.text.trim().toLowerCase(),
                  phone: phoneController.text.trim(),
                  address: addressController.text.trim(),
                  specialization: specializationController.text.trim(),
                  licenseNumber: licenseNumberController.text.trim(),
                  experienceYears: int.tryParse(experienceController.text) ?? 0,
                  hourlyRate: double.tryParse(hourlyRateController.text) ?? 0,
                  baseSalary: double.tryParse(baseSalaryController.text) ?? 0,
                  commissionRate:
                      (double.tryParse(commissionController.text) ?? 0.1),
                  successRate:
                      (double.tryParse(successRateController.text) ?? 0.7) /
                          (successRateController.text.contains('%') ? 100 : 1),
                  bio: bioController.text.trim(),
                  languages: languages,
                  certifications: certifications,
                  createdAt: DateTime.now(),
                );

                // Add both user account and lawyer profile
                await UserStorageService.addUser(lawyerUser);
                await UserStorageService.addLawyer(newLawyer);
                await _loadLawyers();
                Navigator.pop(context);
                _showSuccessSnackBar(
                    'Thêm luật sư và tạo tài khoản thành công');
              } catch (e) {
                _showErrorSnackBar('Có lỗi xảy ra khi thêm luật sư: $e');
              }
            },
            child: const Text('Thêm'),
          ),
        ],
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
          // Search and filters
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
                    hintText: 'Tìm kiếm theo tên, email, chuyên môn...',
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

                const SizedBox(height: 12),

                // Filter row
                Row(
                  children: [
                    Expanded(
                      child: _buildSpecializationFilter(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatusFilter(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lawyers list
          Expanded(
            child: _filteredLawyers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.gavel,
                          size: isMobile ? 48 : 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _lawyers.isEmpty
                              ? 'Chưa có luật sư nào'
                              : 'Không tìm thấy luật sư phù hợp',
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
                    itemCount: _filteredLawyers.length,
                    itemBuilder: (context, index) {
                      final lawyer = _filteredLawyers[index];
                      return _buildLawyerCard(lawyer);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLawyerDialog,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildLawyerCard(Lawyer lawyer) {
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
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  radius: isMobile ? 20 : 24,
                  child: Text(
                    lawyer.name[0].toUpperCase(),
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
                        lawyer.name,
                        style: TextStyle(
                          fontSize: isMobile ? 15 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        lawyer.specialization,
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
                      horizontal: isMobile ? 6 : 8, vertical: isMobile ? 3 : 4),
                  decoration: BoxDecoration(
                    color: lawyer.isActive ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    lawyer.isActive ? 'Hoạt động' : 'Không hoạt động',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 10 : 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: isMobile ? 12 : 16),

            // Details
            _buildDetailRow(Icons.email, 'Email', lawyer.email),
            _buildDetailRow(Icons.phone, 'Số điện thoại', lawyer.phone),
            _buildDetailRow(Icons.location_on, 'Địa chỉ', lawyer.address),
            _buildDetailRow(Icons.badge, 'Số chứng chỉ', lawyer.licenseNumber),
            _buildDetailRow(
                Icons.timeline, 'Kinh nghiệm', '${lawyer.experienceYears} năm'),
            _buildDetailRow(Icons.attach_money, 'Phí tư vấn',
                '${lawyer.hourlyRate.toStringAsFixed(0)} VNĐ/giờ'),
            _buildDetailRow(Icons.payments, 'Lương cứng',
                '${lawyer.baseSalary.toStringAsFixed(0)} VNĐ/tháng'),
            _buildDetailRow(Icons.percent, 'Hoa hồng',
                '${(lawyer.commissionRate * 100).toStringAsFixed(0)}%'),
            _buildDetailRow(Icons.trending_up, 'Tỉ lệ thành công',
                '${(lawyer.successRate * 100).toStringAsFixed(0)}%'),
            _buildDetailRow(Icons.work_history, 'Vụ án đang xử lý',
                '${lawyer.ongoingCases} vụ'),

            if (lawyer.bio.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDetailRow(Icons.info, 'Tiểu sử', lawyer.bio),
            ],

            if (lawyer.languages.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.language,
                      size: isMobile ? 14 : 16, color: Colors.grey[600]),
                  SizedBox(width: isMobile ? 6 : 8),
                  Text(
                    'Ngôn ngữ: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      fontSize: isMobile ? 13 : 14,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      lawyer.languages.join(', '),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isMobile ? 13 : 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (lawyer.certifications.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.verified,
                      size: isMobile ? 14 : 16, color: Colors.grey[600]),
                  SizedBox(width: isMobile ? 6 : 8),
                  Text(
                    'Chứng chỉ: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      fontSize: isMobile ? 13 : 14,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      lawyer.certifications.join(', '),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isMobile ? 13 : 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: isMobile ? 12 : 16),

            // Actions
            if (isMobile) ...[
              // Mobile layout - stacked buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showEditLawyerDialog(lawyer),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Chỉnh sửa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showDeleteDialog(lawyer),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Xóa', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ] else ...[
              // Desktop layout - inline buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showEditLawyerDialog(lawyer),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Chỉnh sửa'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _showDeleteDialog(lawyer),
                    icon: const Icon(Icons.delete, color: Colors.red),
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

  void _showEditLawyerDialog(Lawyer lawyer) {
    final nameController = TextEditingController(text: lawyer.name);
    final emailController = TextEditingController(text: lawyer.email);
    final phoneController = TextEditingController(text: lawyer.phone);
    final addressController = TextEditingController(text: lawyer.address);
    final specializationController =
        TextEditingController(text: lawyer.specialization);
    final licenseNumberController =
        TextEditingController(text: lawyer.licenseNumber);
    final experienceController =
        TextEditingController(text: lawyer.experienceYears.toString());
    final hourlyRateController =
        TextEditingController(text: lawyer.hourlyRate.toStringAsFixed(0));
    final baseSalaryController =
        TextEditingController(text: lawyer.baseSalary.toStringAsFixed(0));
    final commissionController = TextEditingController(
        text: (lawyer.commissionRate * 100).toStringAsFixed(0));
    final successRateController = TextEditingController(
        text: (lawyer.successRate * 100).toStringAsFixed(0));
    final bioController = TextEditingController(text: lawyer.bio);
    final languagesController =
        TextEditingController(text: lawyer.languages.join(', '));
    final certificationsController =
        TextEditingController(text: lawyer.certifications.join(', '));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa thông tin luật sư'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                      labelText: 'Họ và tên', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                      labelText: 'Email', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                      labelText: 'Số điện thoại',
                      border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                      labelText: 'Địa chỉ', border: OutlineInputBorder()),
                  maxLines: 2),
              const SizedBox(height: 12),
              TextField(
                  controller: specializationController,
                  decoration: const InputDecoration(
                      labelText: 'Chuyên môn', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                  controller: licenseNumberController,
                  decoration: const InputDecoration(
                      labelText: 'Số chứng chỉ hành nghề',
                      border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                  controller: experienceController,
                  decoration: const InputDecoration(
                      labelText: 'Số năm kinh nghiệm',
                      border: OutlineInputBorder()),
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextField(
                  controller: hourlyRateController,
                  decoration: const InputDecoration(
                      labelText: 'Phí tư vấn/giờ (VNĐ)',
                      border: OutlineInputBorder()),
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              TextField(
                  controller: baseSalaryController,
                  decoration: const InputDecoration(
                      labelText: 'Lương cứng/tháng (VNĐ)',
                      border: OutlineInputBorder()),
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: commissionController,
                        decoration: const InputDecoration(
                            labelText: 'Hoa hồng (%)',
                            border: OutlineInputBorder()),
                        keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(
                    child: TextField(
                        controller: successRateController,
                        decoration: const InputDecoration(
                            labelText: 'Tỉ lệ thành công (%)',
                            border: OutlineInputBorder()),
                        keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 12),
              TextField(
                  controller: bioController,
                  decoration: const InputDecoration(
                      labelText: 'Tiểu sử', border: OutlineInputBorder()),
                  maxLines: 3),
              const SizedBox(height: 12),
              TextField(
                  controller: languagesController,
                  decoration: const InputDecoration(
                      labelText: 'Ngôn ngữ (cách nhau bởi dấu phẩy)',
                      border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                  controller: certificationsController,
                  decoration: const InputDecoration(
                      labelText: 'Chứng chỉ (cách nhau bởi dấu phẩy)',
                      border: OutlineInputBorder())),
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
                final updated = lawyer.copyWith(
                  name: nameController.text.trim(),
                  email: emailController.text.trim().toLowerCase(),
                  phone: phoneController.text.trim(),
                  address: addressController.text.trim(),
                  specialization: specializationController.text.trim(),
                  licenseNumber: licenseNumberController.text.trim(),
                  experienceYears: int.tryParse(experienceController.text) ??
                      lawyer.experienceYears,
                  hourlyRate: double.tryParse(hourlyRateController.text) ??
                      lawyer.hourlyRate,
                  baseSalary: double.tryParse(baseSalaryController.text) ??
                      lawyer.baseSalary,
                  commissionRate: (double.tryParse(commissionController.text) ??
                          (lawyer.commissionRate * 100)) /
                      (commissionController.text.contains('%') ? 100 : 100),
                  successRate: (double.tryParse(successRateController.text) ??
                          (lawyer.successRate * 100)) /
                      (successRateController.text.contains('%') ? 100 : 100),
                  bio: bioController.text.trim(),
                  languages: languagesController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList(),
                  certifications: certificationsController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList(),
                  updatedAt: DateTime.now(),
                );
                await UserStorageService.updateLawyer(updated);
                await _loadLawyers();
                if (mounted) Navigator.pop(context);
                _showSuccessSnackBar('Cập nhật luật sư thành công');
              } catch (e) {
                _showErrorSnackBar('Lỗi khi cập nhật: $e');
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  String _validateLawyerInput(
      String name,
      String email,
      String password,
      String phone,
      String address,
      String specialization,
      String licenseNumber,
      String experience,
      String hourlyRate) {
    if (name.trim().isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }
    if (name.trim().length < 2) {
      return 'Họ và tên phải có ít nhất 2 ký tự';
    }
    if (email.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim())) {
      return 'Email không hợp lệ';
    }
    if (password.trim().isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (password.trim().length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    if (phone.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    if (!RegExp(r'^[0-9]{10,11}$').hasMatch(phone.trim())) {
      return 'Số điện thoại phải có 10-11 chữ số';
    }
    if (address.trim().isEmpty) {
      return 'Vui lòng nhập địa chỉ';
    }
    if (specialization.trim().isEmpty) {
      return 'Vui lòng nhập chuyên môn';
    }
    if (licenseNumber.trim().isEmpty) {
      return 'Vui lòng nhập số chứng chỉ hành nghề';
    }
    if (experience.trim().isEmpty) {
      return 'Vui lòng nhập số năm kinh nghiệm';
    }
    final expYears = int.tryParse(experience.trim());
    if (expYears == null || expYears < 0) {
      return 'Số năm kinh nghiệm phải là số dương';
    }
    if (hourlyRate.trim().isEmpty) {
      return 'Vui lòng nhập phí tư vấn';
    }
    final rate = double.tryParse(hourlyRate.trim());
    if (rate == null || rate <= 0) {
      return 'Phí tư vấn phải là số dương';
    }
    return '';
  }

  Widget _buildSpecializationFilter() {
    final uniqueSpecializations = _lawyers
        .map((lawyer) => lawyer.specialization)
        .toSet()
        .toList()
      ..sort();

    return DropdownButtonFormField<String>(
      value: _selectedSpecialization,
      decoration: InputDecoration(
        labelText: 'Chuyên môn',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
      items: [
        const DropdownMenuItem(value: 'all', child: Text('Tất cả chuyên môn')),
        ...uniqueSpecializations.map((specialization) => DropdownMenuItem(
              value: specialization,
              child: Text(specialization),
            )),
      ],
      onChanged: (value) {
        setState(() {
          _selectedSpecialization = value ?? 'all';
          _applyFilters();
        });
      },
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Trạng thái',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
      items: const [
        DropdownMenuItem(value: 'all', child: Text('Tất cả')),
        DropdownMenuItem(value: 'active', child: Text('Hoạt động')),
        DropdownMenuItem(value: 'inactive', child: Text('Không hoạt động')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedStatus = value ?? 'all';
          _applyFilters();
        });
      },
    );
  }
}
