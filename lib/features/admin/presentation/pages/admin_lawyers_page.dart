import 'package:flutter/material.dart';
import '../../data/services/user_storage_service.dart';
import '../../data/services/admin_api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/lawyer.dart';
import '../../data/models/admin_user.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/firebase/storage_image.dart';

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

        // Enrich with Users API (email/phone) if missing in profile payload
        try {
          final usersResp =
              await api.getUsers(includeInactive: true, role: 'Lawyer');
          final uraw = usersResp.data;
          final List users = uraw is List
              ? uraw
              : (uraw is Map<String, dynamic>
                  ? (uraw['result'] ?? uraw['Result'] ?? []) as List
                  : <dynamic>[]);
          // Build maps by id and name for best-effort merging
          final Map<String, Map<String, dynamic>> idMap = {};
          final Map<String, Map<String, dynamic>> nameMap = {};
          for (final u in users) {
            if (u is Map<String, dynamic>) {
              final id = (u['id'] ?? u['Id'] ?? '').toString();
              final fullName =
                  (u['fullName'] ?? u['FullName'] ?? u['name'] ?? '')
                      .toString();
              idMap[id] = u;
              if (fullName.isNotEmpty) nameMap[fullName.toLowerCase()] = u;
            }
          }
          for (var i = 0; i < lawyers.length; i++) {
            final l = lawyers[i];
            if (l.email.isEmpty || l.phone.isEmpty) {
              Map<String, dynamic>? u;
              // Try exact id match first (common when ids align)
              u = idMap[l.id];
              // Fallback: name match
              u ??= nameMap[l.name.toLowerCase()];
              if (u != null) {
                lawyers[i] = l.copyWith(
                  email: (u['email'] ?? u['Email'] ?? l.email).toString(),
                  phone: (u['phoneNumber'] ?? u['phone'] ?? l.phone).toString(),
                );
              }
            }
          }
        } catch (_) {}
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

  Future<void> _toggleLawyerActive(Lawyer lawyer) async {
    try {
      final targetActive = !lawyer.isActive;
      // Call Users API first
      try {
        if (targetActive) {
          await AdminApiService().restoreUser(lawyer.id);
        } else {
          await AdminApiService().softDeleteUser(lawyer.id);
        }
      } catch (_) {
        // Fallback: attempt to update simple profile flag
        try {
          await AdminApiService().updateLawyerSimple(
              int.tryParse(lawyer.id) ?? 0, {'isActive': targetActive});
        } catch (_) {}
      }
      // Update local storage
      final updated = lawyer.copyWith(isActive: targetActive);
      await UserStorageService.updateLawyer(updated);
      setState(() {
        final idx = _lawyers.indexWhere((l) => l.id == lawyer.id);
        if (idx != -1) _lawyers[idx] = updated;
        _applyFilters();
      });
      _showSuccessSnackBar(
          targetActive ? 'Đã bật hoạt động' : 'Đã tắt hoạt động');
    } catch (e) {
      _showErrorSnackBar('Lỗi khi cập nhật trạng thái: $e');
    }
  }

  void _showAddLawyerDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    // Remove password from edit UI
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final specializationController = TextEditingController();
    final licenseNumberController = TextEditingController();
    final experienceController = TextEditingController();
    final hourlyRateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        title: const Text('Thêm luật sư mới',
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
              // Password is generated silently to avoid extra field in UI
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
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Địa chỉ',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: specializationController,
                decoration: InputDecoration(
                  labelText: 'Chuyên môn',
                  prefixIcon: const Icon(Icons.gavel),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: licenseNumberController,
                decoration: InputDecoration(
                  labelText: 'Số chứng chỉ hành nghề',
                  prefixIcon: const Icon(Icons.workspace_premium),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: experienceController,
                decoration: InputDecoration(
                  labelText: 'Số năm kinh nghiệm',
                  prefixIcon: const Icon(Icons.timeline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: hourlyRateController,
                decoration: InputDecoration(
                  labelText: 'Phí tư vấn/giờ (VNĐ)',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
              ),
              // Advanced, non-essential fields are hidden for consistency with backend
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
              final generatedPassword =
                  'Ls@' + DateTime.now().millisecondsSinceEpoch.toString();
              final validationResult = _validateLawyerInput(
                nameController.text,
                emailController.text,
                generatedPassword,
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
                final languages = <String>[];
                final certifications = <String>[];

                // Create lawyer user account
                final lawyerUser = User(
                  id: 'user_lawyer_${DateTime.now().millisecondsSinceEpoch}',
                  email: emailController.text.trim().toLowerCase(),
                  password: generatedPassword,
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
                  baseSalary: 0,
                  commissionRate: 0.1,
                  successRate: 0.7,
                  bio: '',
                  languages: languages,
                  certifications: certifications,
                  createdAt: DateTime.now(),
                );

                // Add both user account and lawyer profile (local)
                await UserStorageService.addUser(lawyerUser);
                await UserStorageService.addLawyer(newLawyer);

                // Best-effort: create backend user (to supply email/phone via Users API)
                try {
                  await AdminApiService().createUser({
                    'fullName': lawyerUser.name,
                    'email': lawyerUser.email,
                    'password': generatedPassword,
                    'phoneNumber': phoneController.text.trim(),
                    'role': 'Lawyer',
                    'isActive': true,
                  });
                } catch (_) {}
                await _loadLawyers();
                Navigator.pop(context);
                _showSuccessSnackBar(
                    'Thêm luật sư và tạo tài khoản thành công');
              } catch (e) {
                _showErrorSnackBar('Có lỗi xảy ra khi thêm luật sư: $e');
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(96, 44)),
            child: const Text('Thêm'),
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
    final addressController = TextEditingController(text: lawyer.address);
    final specializationController =
        TextEditingController(text: lawyer.specialization);
    final licenseNumberController =
        TextEditingController(text: lawyer.licenseNumber);
    final experienceController =
        TextEditingController(text: lawyer.experienceYears.toString());
    final hourlyRateController =
        TextEditingController(text: lawyer.hourlyRate.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        title: const Text(
          'Chỉnh sửa thông tin luật sư',
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
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              // Mật khẩu không hiển thị trong UI chỉnh sửa
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Địa chỉ',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: specializationController,
                decoration: InputDecoration(
                  labelText: 'Chuyên môn',
                  prefixIcon: const Icon(Icons.gavel),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: licenseNumberController,
                decoration: InputDecoration(
                  labelText: 'Số chứng chỉ hành nghề',
                  prefixIcon: const Icon(Icons.workspace_premium),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: experienceController,
                decoration: InputDecoration(
                  labelText: 'Số năm kinh nghiệm',
                  prefixIcon: const Icon(Icons.timeline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: hourlyRateController,
                decoration: InputDecoration(
                  labelText: 'Phí tư vấn/giờ (VNĐ)',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
              ),
              // Ẩn các trường nâng cao để khớp payload tối thiểu
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
                  updatedAt: DateTime.now(),
                );
                await UserStorageService.updateLawyer(updated);
                // Sync associated user account (name/email). Password unchanged
                await UserStorageService.syncLawyerUserAccount(
                    oldEmail: originalEmail,
                    name: updated.name,
                    newEmail: updated.email);
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

  Widget _buildSearchAndFilters(double screenWidth, bool isTablet) {
    // Match Customers/Appointments filter area: flat, full-width, light bg
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      color: Colors.grey[50],
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
      padding:
          EdgeInsets.symmetric(horizontal: 12, vertical: isTablet ? 16 : 12),
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

    final bool isHttp = lawyer.imageUrl.isNotEmpty &&
        lawyer.imageUrl.toLowerCase().startsWith('http');

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 16 : 12),
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
                    child: lawyer.imageUrl.isEmpty
                        ? _buildAvatarFallback(lawyer, screenWidth, isTablet)
                        : isHttp
                            ? Image.network(
                                lawyer.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildAvatarFallback(
                                        lawyer, screenWidth, isTablet),
                              )
                            : StorageImage(
                                path: lawyer.imageUrl,
                                width: isTablet ? 64 : 56,
                                height: isTablet ? 64 : 56,
                                fit: BoxFit.cover,
                              ),
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
                              color: lawyer.isActive
                                  ? AppColors.successContainer
                                  : AppColors.errorContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              lawyer.isActive ? 'Hoạt động' : 'Không hoạt động',
                              style: TextStyle(
                                color: lawyer.isActive
                                    ? AppColors.onSuccessContainer
                                    : AppColors.onErrorContainer,
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
                    label:
                        lawyer.email.isEmpty ? 'Chưa cập nhật' : lawyer.email,
                    style: chipTextStyle),
                _infoChip(
                    icon: Icons.phone,
                    label:
                        lawyer.phone.isEmpty ? 'Chưa cập nhật' : lawyer.phone,
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
                // Toggle active instead of delete
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleLawyerActive(lawyer),
                    icon: Icon(
                      lawyer.isActive ? Icons.visibility_off : Icons.visibility,
                      size: isTablet ? 18 : 16,
                      color:
                          lawyer.isActive ? AppColors.error : AppColors.success,
                    ),
                    label: Text(
                      lawyer.isActive ? 'Tắt hoạt động' : 'Bật hoạt động',
                      style: TextStyle(
                        color: lawyer.isActive
                            ? AppColors.error
                            : AppColors.success,
                        fontSize: isTablet ? 14 : 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: lawyer.isActive
                            ? AppColors.error
                            : AppColors.success,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
