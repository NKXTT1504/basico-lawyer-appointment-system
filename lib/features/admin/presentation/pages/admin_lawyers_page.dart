import 'package:flutter/material.dart';
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
  bool _isLoading = true;

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
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Có lỗi xảy ra: $e');
    }
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
              if (nameController.text.isNotEmpty &&
                  emailController.text.isNotEmpty &&
                  passwordController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty &&
                  addressController.text.isNotEmpty &&
                  specializationController.text.isNotEmpty &&
                  licenseNumberController.text.isNotEmpty &&
                  experienceController.text.isNotEmpty &&
                  hourlyRateController.text.isNotEmpty) {
                try {
                  // Check if email already exists
                  final existingUsers = await UserStorageService.getUsers();
                  if (existingUsers.any(
                      (user) => user.email == emailController.text.trim())) {
                    _showErrorSnackBar('Email đã tồn tại');
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
                    email: emailController.text.trim(),
                    password: passwordController.text,
                    name: nameController.text.trim(),
                    role: UserRole.lawyer,
                    createdAt: DateTime.now(),
                  );

                  // Create lawyer profile
                  final newLawyer = Lawyer(
                    id: 'law_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text,
                    email: emailController.text,
                    phone: phoneController.text,
                    address: addressController.text,
                    specialization: specializationController.text,
                    licenseNumber: licenseNumberController.text,
                    experienceYears:
                        int.tryParse(experienceController.text) ?? 0,
                    hourlyRate: double.tryParse(hourlyRateController.text) ?? 0,
                    bio: bioController.text,
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
                  _showErrorSnackBar('Có lỗi xảy ra: $e');
                }
              } else {
                _showErrorSnackBar('Vui lòng điền đầy đủ thông tin bắt buộc');
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý luật sư'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLawyers,
          ),
        ],
      ),
      body: _lawyers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.gavel,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có luật sư nào',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _lawyers.length,
              itemBuilder: (context, index) {
                final lawyer = _lawyers[index];
                return _buildLawyerCard(lawyer);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLawyerDialog,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildLawyerCard(Lawyer lawyer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    lawyer.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lawyer.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        lawyer.specialization,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: lawyer.isActive ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    lawyer.isActive ? 'Hoạt động' : 'Không hoạt động',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Details
            _buildDetailRow(Icons.email, 'Email', lawyer.email),
            _buildDetailRow(Icons.phone, 'Số điện thoại', lawyer.phone),
            _buildDetailRow(Icons.location_on, 'Địa chỉ', lawyer.address),
            _buildDetailRow(Icons.badge, 'Số chứng chỉ', lawyer.licenseNumber),
            _buildDetailRow(
                Icons.timeline, 'Kinh nghiệm', '${lawyer.experienceYears} năm'),
            _buildDetailRow(Icons.attach_money, 'Phí tư vấn',
                '${lawyer.hourlyRate.toStringAsFixed(0)} VNĐ/giờ'),

            if (lawyer.bio.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDetailRow(Icons.info, 'Tiểu sử', lawyer.bio),
            ],

            if (lawyer.languages.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.language, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Ngôn ngữ: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      lawyer.languages.join(', '),
                      style: TextStyle(color: Colors.grey[600]),
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
                  Icon(Icons.verified, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Chứng chỉ: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      lawyer.certifications.join(', '),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement edit functionality
                      _showErrorSnackBar(
                          'Chức năng chỉnh sửa đang được phát triển');
                    },
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
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
