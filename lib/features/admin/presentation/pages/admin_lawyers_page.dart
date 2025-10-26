import 'package:flutter/material.dart';
import '../../data/services/user_storage_service.dart';
import '../../data/services/admin_api_service.dart';
import '../../data/models/lawyer.dart';
import '../../data/models/admin_user.dart';
import 'package:go_router/go_router.dart';

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
      final current = await UserStorageService.getCurrentUser();
      if (current == null || current.role != UserRole.admin) {
        if (mounted)
          context.go(
              current?.role == UserRole.lawyer ? '/lawyer/dashboard' : '/home');
        return;
      }
      // Prefer backend if available
      try {
        final api = AdminApiService();
        final resp = await api.getAllLawyersProfile();
        final data = resp.data is Map<String, dynamic>
            ? resp.data as Map<String, dynamic>
            : <String, dynamic>{};
        final List list = (data['result'] ?? data['Result'] ?? []) as List;
        final lawyers = list
            .map((e) => Lawyer.fromJson(_mapLawyerProfileToLocal(e)))
            .toList();
        setState(() {
          _lawyers = lawyers;
          _applyFilters();
          _isLoading = false;
        });
        return;
      } catch (_) {
        // Fallback to local storage if API fails
      }
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

  Map<String, dynamic> _mapLawyerProfileToLocal(dynamic json) {
    final Map<String, dynamic> m =
        json is Map<String, dynamic> ? json : <String, dynamic>{};
    return {
      // ID
      'id': (m['id'] ?? m['Id'] ?? '').toString(),
      // Tên không có trong payload mẫu → fallback theo userId/ID
      'name': (m['fullName'] ?? m['name'] ?? 'Luật sư #${m['id'] ?? ''}')
          .toString(),
      // Email/Phone không có → để trống
      'email': (m['email'] ?? '').toString(),
      'phone': (m['phone'] ?? '').toString(),
      // Địa chỉ dùng field description trong payload
      'address': (m['address'] ?? m['description'] ?? '').toString(),
      // Chuyên môn lấy tên lĩnh vực đầu tiên trong practiceAreas
      'specialization': ((m['spec'] ?? m['specialization']) ??
              ((m['practiceAreas'] is List &&
                      (m['practiceAreas'] as List).isNotEmpty)
                  ? (((m['practiceAreas'] as List).first as Map)['name'] ?? '')
                      .toString()
                  : ''))
          .toString(),
      'licenseNumber': (m['licenseNum'] ?? m['licenseNumber'] ?? '').toString(),
      'experienceYears': m['expYears'] ?? m['experienceYears'] ?? 0,
      'hourlyRate': (m['pricePerHour'] ?? m['hourlyRate'] ?? 0).toDouble(),
      'baseSalary': 0,
      'commissionRate': 0.1,
      'successRate': ((m['rating'] ?? 0) is num)
          ? (((m['rating'] as num).toDouble() / 5.0).clamp(0.0, 1.0))
          : 0.7,
      'bio': (m['bio'] ?? '').toString(),
      'imageUrl': (m['img'] ?? m['imageUrl'] ?? '').toString(),
      'languages': <String>[],
      'certifications': <String>[],
      'createdAt':
          (m['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
      'updatedAt':
          (m['updatedAt'] ?? DateTime.now().toIso8601String()).toString(),
      'isActive': m['isActive'] == null ? true : (m['isActive'] as bool),
    };
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
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth *
                (isTablet ? 0.08 : 0.04), // 8% for tablet, 4% for mobile
            vertical: screenHeight * 0.02, // 2% of screen height
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Title
              _buildPageTitle(screenWidth, isTablet),
              SizedBox(height: screenHeight * 0.03), // 3% of screen height

              // Search and filters
              _buildSearchAndFilters(screenWidth, isTablet),
              SizedBox(height: screenHeight * 0.03), // 3% of screen height

              // Lawyers list
              Expanded(
                child: _filteredLawyers.isEmpty
                    ? _buildEmptyState(screenWidth, isTablet)
                    : _buildLawyersGrid(screenWidth, isTablet),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLawyerDialog,
        backgroundColor: const Color(0xFF1E3A8A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPageTitle(double screenWidth, bool isTablet) {
    return Text(
      'QUẢN LÝ LUẬT SƯ',
      style: TextStyle(
        fontSize: screenWidth *
            (isTablet ? 0.07 : 0.06), // 7% for tablet, 6% for mobile
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1C1B1F),
      ),
    );
  }

  Widget _buildSearchAndFilters(double screenWidth, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(screenWidth * (isTablet ? 0.04 : 0.03)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _applyFilters();
              });
            },
            style: TextStyle(fontSize: isTablet ? screenWidth * 0.035 : 14),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm theo tên, email, chuyên môn...',
              hintStyle:
                  TextStyle(fontSize: isTablet ? screenWidth * 0.03 : 13),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey[600],
                size: isTablet ? 22 : 20,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey[600],
                        size: isTablet ? 20 : 18,
                      ),
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
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF1E3A8A), width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isTablet ? 16 : 12,
                vertical: isTablet ? 16 : 12,
              ),
            ),
          ),

          SizedBox(height: screenWidth * 0.03),

          // Filter row
          if (isTablet) ...[
            Row(
              children: [
                Expanded(
                    child: _buildSpecializationFilter(screenWidth, isTablet)),
                SizedBox(width: screenWidth * 0.03),
                Expanded(child: _buildStatusFilter(screenWidth, isTablet)),
              ],
            ),
          ] else ...[
            // Stack filters vertically on small phones to avoid overflow
            _buildSpecializationFilter(screenWidth, isTablet),
            const SizedBox(height: 12),
            _buildStatusFilter(screenWidth, isTablet),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(double screenWidth, bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.gavel,
            size: isTablet ? 64 : 48,
            color: Colors.grey[400],
          ),
          SizedBox(height: screenWidth * 0.04),
          Text(
            _lawyers.isEmpty
                ? 'Chưa có luật sư nào'
                : 'Không tìm thấy luật sư phù hợp',
            style: TextStyle(
              fontSize: screenWidth * (isTablet ? 0.045 : 0.04),
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLawyersGrid(double screenWidth, bool isTablet) {
    return GridView.builder(
      padding: EdgeInsets.all(isTablet ? screenWidth * 0.02 : 12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 2 : 1,
        crossAxisSpacing: isTablet ? screenWidth * 0.03 : 12,
        mainAxisSpacing: isTablet ? screenWidth * 0.03 : 12,
        // Adaptive fixed extent for consistency
        mainAxisExtent: isTablet ? 340 : 420,
      ),
      itemCount: _filteredLawyers.length,
      itemBuilder: (context, index) {
        final lawyer = _filteredLawyers[index];
        return _buildLawyerCard(lawyer, screenWidth, isTablet);
      },
    );
  }

  Widget _buildLawyerCard(Lawyer lawyer, double screenWidth, bool isTablet) {
    final chipTextStyle = TextStyle(
      color: Colors.grey[800],
      fontSize: isTablet ? 14 : 12,
      fontWeight: FontWeight.w600,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isTablet ? 20 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: SizedBox(
                  width: isTablet ? 64 : 56,
                  height: isTablet ? 64 : 56,
                  child: (lawyer.imageUrl.isNotEmpty &&
                          !lawyer.imageUrl
                              .contains('firebasestorage.googleapis.com'))
                      ? Image.network(
                          lawyer.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildAvatarFallback(
                              lawyer, screenWidth, isTablet),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              width: isTablet ? 64 : 56,
                              height: isTablet ? 64 : 56,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          cacheHeight: 128, // Cache để tránh load lại nhiều lần
                          cacheWidth: 128,
                        )
                      : _buildAvatarFallback(lawyer, screenWidth, isTablet),
                ),
              ),
              const SizedBox(width: 12),
              // Title and meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lawyer.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isTablet ? 20 : 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E3A8A),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: (lawyer.isActive
                                ? const Color(0xFFE7F6EC)
                                : const Color(0xFFFCE8E8)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            lawyer.isActive ? 'Hoạt động' : 'Không hoạt động',
                            style: TextStyle(
                              color: lawyer.isActive
                                  ? const Color(0xFF1B5E20)
                                  : const Color(0xFFB71C1C),
                              fontSize: isTablet ? 12 : 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lawyer.specialization,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Info chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoChip(
                  icon: Icons.email,
                  label: lawyer.email.isEmpty ? 'Chưa cập nhật' : lawyer.email,
                  style: chipTextStyle),
              _infoChip(
                  icon: Icons.phone,
                  label: lawyer.phone.isEmpty ? 'Chưa cập nhật' : lawyer.phone,
                  style: chipTextStyle),
              _infoChip(
                  icon: Icons.timeline,
                  label: '${lawyer.experienceYears} năm',
                  style: chipTextStyle),
              _infoChip(
                  icon: Icons.attach_money,
                  label: '${lawyer.hourlyRate.toStringAsFixed(0)} VNĐ/giờ',
                  style: chipTextStyle),
              if (lawyer.address.isNotEmpty)
                _infoChip(
                    icon: Icons.place,
                    label: lawyer.address,
                    style: chipTextStyle),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showEditLawyerDialog(lawyer),
                  icon: Icon(Icons.edit, size: isTablet ? 18 : 16),
                  label: Text('Chỉnh sửa',
                      style: TextStyle(fontSize: isTablet ? 14 : 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () => _showDeleteDialog(lawyer),
                icon: const Icon(Icons.delete, color: Colors.red),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.08),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(
      {required IconData icon,
      required String label,
      required TextStyle style}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(label, style: style),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(
      Lawyer lawyer, double screenWidth, bool isTablet) {
    return Container(
      color: const Color(0xFF1E3A8A).withOpacity(0.08),
      child: Center(
        child: Text(
          (lawyer.name.isNotEmpty ? lawyer.name[0] : 'L').toUpperCase(),
          style: TextStyle(
            color: const Color(0xFF1E3A8A),
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * (isTablet ? 0.05 : 0.06),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      double screenWidth, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.02),
      child: Row(
        children: [
          Icon(
            icon,
            size: screenWidth * (isTablet ? 0.04 : 0.045),
            color: Colors.grey[600],
          ),
          SizedBox(width: screenWidth * 0.02),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontSize: screenWidth * (isTablet ? 0.035 : 0.04),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: screenWidth * (isTablet ? 0.035 : 0.04),
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
    final originalEmail = lawyer.email;
    final phoneController = TextEditingController(text: lawyer.phone);
    final passwordController = TextEditingController();
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
              FutureBuilder<User?>(
                future: UserStorageService.getUserByEmail(originalEmail),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  if (snapshot.data != null &&
                      passwordController.text.isEmpty) {
                    passwordController.text = snapshot.data!.password;
                  }
                  return TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu đăng nhập',
                      border: OutlineInputBorder(),
                    ),
                  );
                },
              ),
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
                // Sync associated user account (name/email/password)
                await UserStorageService.syncLawyerUserAccount(
                  oldEmail: originalEmail,
                  name: updated.name,
                  newEmail: updated.email,
                  newPassword: passwordController.text,
                );
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

  Widget _buildSpecializationFilter(double screenWidth, bool isTablet) {
    final uniqueSpecializations = _lawyers
        .map((lawyer) => lawyer.specialization)
        .toSet()
        .toList()
      ..sort();

    return DropdownButtonFormField<String>(
      value: _selectedSpecialization,
      style: TextStyle(fontSize: screenWidth * 0.035),
      decoration: InputDecoration(
        labelText: 'Chuyên môn',
        labelStyle: TextStyle(fontSize: screenWidth * 0.035),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03,
          vertical: screenWidth * 0.02,
        ),
        isDense: true,
      ),
      items: [
        DropdownMenuItem(
          value: 'all',
          child: Text(
            'Tất cả chuyên môn',
            style: TextStyle(fontSize: screenWidth * 0.035),
          ),
        ),
        ...uniqueSpecializations.map((specialization) => DropdownMenuItem(
              value: specialization,
              child: Text(
                specialization,
                style: TextStyle(fontSize: screenWidth * 0.035),
              ),
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

  Widget _buildStatusFilter(double screenWidth, bool isTablet) {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      style: TextStyle(fontSize: screenWidth * 0.035),
      decoration: InputDecoration(
        labelText: 'Trạng thái',
        labelStyle: TextStyle(fontSize: screenWidth * 0.035),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03,
          vertical: screenWidth * 0.02,
        ),
        isDense: true,
      ),
      items: [
        DropdownMenuItem(
          value: 'all',
          child: Text(
            'Tất cả',
            style: TextStyle(fontSize: screenWidth * 0.035),
          ),
        ),
        DropdownMenuItem(
          value: 'active',
          child: Text(
            'Hoạt động',
            style: TextStyle(fontSize: screenWidth * 0.035),
          ),
        ),
        DropdownMenuItem(
          value: 'inactive',
          child: Text(
            'Không hoạt động',
            style: TextStyle(fontSize: screenWidth * 0.035),
          ),
        ),
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
