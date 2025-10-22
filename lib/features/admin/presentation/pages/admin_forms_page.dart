import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/admin_api_service.dart';
import '../../data/services/user_storage_service.dart';
import '../../data/models/admin_user.dart';

class AdminFormsPage extends StatefulWidget {
  const AdminFormsPage({super.key});

  @override
  State<AdminFormsPage> createState() => _AdminFormsPageState();
}

class _AdminFormsPageState extends State<AdminFormsPage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _loading = true;
  List<Map<String, dynamic>> _forms = [];
  bool _isCreate = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final current = await UserStorageService.getCurrentUser();
      if (current == null || current.role != UserRole.admin) {
        if (mounted) context.go('/home');
        return;
      }
      final api = AdminApiService();
      final resp = await api.getForms();
      final data = resp.data is List
          ? resp.data as List
          : (resp.data['result'] ?? resp.data['Result'] ?? []) as List;
      setState(() {
        _forms = data.map((e) => Map<String, dynamic>.from(e)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      _showSnack('Lỗi tải danh sách form: $e', isError: true);
    }
  }

  Future<void> _create() async {
    final name = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    if (name.isEmpty) {
      _showSnack('Vui lòng nhập tên form', isError: true);
      return;
    }
    try {
      final api = AdminApiService();
      await api.createForm({'name': name, 'description': desc});
      _titleCtrl.clear();
      _descCtrl.clear();
      await _fetch();
      _showSnack('Tạo form thành công');
    } catch (e) {
      _showSnack('Tạo form thất bại: $e', isError: true);
    }
  }

  Future<void> _edit(Map<String, dynamic> form) async {
    final nameCtrl = TextEditingController(text: (form['name'] ?? '').toString());
    final descCtrl =
        TextEditingController(text: (form['description'] ?? '').toString());
    final id = int.tryParse((form['id'] ?? form['Id'] ?? '0').toString()) ?? 0;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sửa form'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên form',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final api = AdminApiService();
                await api.updateForm(id, {
                  'name': nameCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                });
                if (mounted) Navigator.pop(context);
                await _fetch();
                _showSnack('Cập nhật form thành công');
              } catch (e) {
                _showSnack('Cập nhật thất bại: $e', isError: true);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(Map<String, dynamic> form) async {
    final id = int.tryParse((form['id'] ?? form['Id'] ?? '0').toString()) ?? 0;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa form'),
        content: Text('Bạn chắc chắn muốn xóa "${form['name']}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final api = AdminApiService();
      await api.deleteForm(id);
      await _fetch();
      _showSnack('Đã xóa form');
    } catch (e) {
      _showSnack('Xóa thất bại: $e', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? Colors.red : Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * (isTablet ? 0.08 : 0.04),
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'QUẢN LÍ FORM',
                style: TextStyle(
                  fontSize: width * (isTablet ? 0.07 : 0.06),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1C1B1F),
                ),
              ),
              const SizedBox(height: 16),
              // Toggle actions similar to the website header (Danh sách / Tạo mới)
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => setState(() => _isCreate = false),
                    style: OutlinedButton.styleFrom(
                      backgroundColor:
                          _isCreate ? Colors.white : const Color(0xFFEEF2FF),
                    ),
                    child: const Text('Danh sách form'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => setState(() => _isCreate = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isCreate ? const Color(0xFF1E3A8A) : Colors.grey[300],
                      foregroundColor: _isCreate ? Colors.white : Colors.black87,
                    ),
                    child: const Text('Tạo form mới'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_isCreate)
                Container(
                padding: EdgeInsets.all(width * (isTablet ? 0.04 : 0.03)),
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
                  children: [
                    TextField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tên form',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Placeholder for file upload (BE FormController hiện chưa nhận file)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Tải file (tuỳ chọn)',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showSnack('BE hiện chưa hỗ trợ upload file cho Form. Sẽ gửi tên/mô tả.',
                              isError: false);
                        },
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Chọn tệp'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _create,
                        child: const Text('Thêm mới'),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isCreate) const SizedBox(height: 16),

              // List view
              Expanded(
                child: _forms.isEmpty
                    ? Center(
                        child: Text(
                          'Chưa có form nào',
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isTablet ? 18 : 16),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _forms.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final f = _forms[i];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (f['name'] ?? '').toString(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        (f['description'] ?? '').toString(),
                                        style: TextStyle(color: Colors.grey[600]),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _edit(f),
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                ),
                                IconButton(
                                  onPressed: () => _delete(f),
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


