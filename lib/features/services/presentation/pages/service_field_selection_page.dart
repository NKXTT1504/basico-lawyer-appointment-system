import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../lawyer/data/services/lawyer_api_service.dart';
import '../../data/models/service.dart';

class ServiceFieldSelectionPage extends StatefulWidget {
  final ServiceModel? preselectedService;

  const ServiceFieldSelectionPage({
    super.key,
    this.preselectedService,
  });

  @override
  State<ServiceFieldSelectionPage> createState() =>
      _ServiceFieldSelectionPageState();
}

class _ServiceFieldSelectionPageState extends State<ServiceFieldSelectionPage> {
  List<ServiceModel> _services = [];
  List<String> _fields = [];
  String? _selectedField;
  // Map tên dịch vụ -> tên lĩnh vực
  final Map<String, String> _selectedServices = {};
  bool _isLoading = true;
  String? _error;

  static const String ALL_FIELDS = 'Tất cả lĩnh vực';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final servicesResponse = await LawyerApiService.getServices();
      if (servicesResponse.statusCode == 200) {
        final List<dynamic> data = _extractList(servicesResponse.data);
        final services =
            data.map((e) => ServiceModel.fromJson(_asMap(e))).toList();
        final fields = <String>{};
        for (final service in services) {
          if (service.specialization != null) {
            fields.add(service.specialization!);
          }
        }
        final sortedFields = fields.toList()..sort();
        sortedFields.insert(
            0, ALL_FIELDS); // Thêm mục "Tất cả lĩnh vực" đầu tiên
        setState(() {
          _services = services;
          _fields = sortedFields;
          _isLoading = false;
        });
        // Preselect nếu có
        if (widget.preselectedService != null) {
          _selectedField = widget.preselectedService!.specialization;
          final name = widget.preselectedService!.name;
          if (name != null &&
              name.isNotEmpty &&
              widget.preselectedService!.specialization != null) {
            _selectedServices[name] =
                widget.preselectedService!.specialization!;
          }
        }
      } else {
        setState(() {
          _error = 'Lỗi tải dịch vụ:  ${servicesResponse.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi tải dữ liệu: $e';
        _isLoading = false;
      });
    }
  }

  List<dynamic> _extractList(dynamic body) {
    if (body == null) return const [];
    if (body is List) return body;
    if (body is Map<String, dynamic>) {
      final possibleKeys = <String>[
        'result',
        'data',
        'items',
        'results',
        'value',
        r'$values',
        'list',
        'services',
        'records'
      ];
      for (final key in possibleKeys) {
        final value = body[key];
        if (value is List) return value;
      }
      for (final value in body.values) {
        if (value is List) return value;
      }
    }
    return const [];
  }

  Map<String, dynamic> _asMap(dynamic e) {
    if (e is Map<String, dynamic>) return e;
    if (e is Map) return e.map((k, v) => MapEntry(k.toString(), v));
    return <String, dynamic>{};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn dịch vụ & lĩnh vực'),
        backgroundColor: Colors.blue[50],
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(_error!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Thử lại')),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressIndicator(),
          const SizedBox(height: 32),
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Chọn dịch vụ & lĩnh vực',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800])),
                  const SizedBox(height: 24),
                  _buildDropdown(
                    label: 'Chọn lĩnh vực',
                    hint: '-- Chọn lĩnh vực --',
                    value: _selectedField,
                    items: _fields,
                    onChanged: (value) {
                      setState(() {
                        _selectedField = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildServiceMultiSelect(),
                  const SizedBox(height: 16),
                  _buildSelectedServicesList(),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _selectedServices.isNotEmpty ? _continue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Tiếp tục',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildBenefitsSection(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildProgressStep(
          number: 1,
          title: 'Chọn dịch vụ & luật sư',
          isActive: true,
        ),
        Expanded(
          child: Container(
            height: 2,
            color: Colors.grey[300],
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
        _buildProgressStep(
          number: 2,
          title: 'Ngày & Giờ',
          isActive: false,
        ),
        Expanded(
          child: Container(
            height: 2,
            color: Colors.grey[300],
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
        _buildProgressStep(
          number: 3,
          title: 'Xác nhận',
          isActive: false,
        ),
      ],
    );
  }

  Widget _buildProgressStep({
    required int number,
    required String title,
    required bool isActive,
  }) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue[600] : Colors.grey[300],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.blue[600] : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildBenefitsSection() {
    final benefits = [
      'Tư vấn toàn diện',
      'Giải pháp cá nhân hóa',
      'Luật sư có chuyên môn',
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn sẽ nhận được gì',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 16),
            ...benefits.asMap().entries.map((entry) {
              final index = entry.key;
              final benefit = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.blue[600],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        benefit,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _continue() {
    final serviceCount = _selectedServices.length;
    // Nếu chọn 2+ dịch vụ, hiển thị modal thông báo cọc
    if (serviceCount >= 2) {
      _showDepositNotification(serviceCount);
    } else {
      _navigateToLawyerSelection();
    }
  }

  void _showDepositNotification(int serviceCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange[600]),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Thông báo đặt cọc',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chính sách đặt lịch nhiều dịch vụ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orange[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bạn đã chọn $serviceCount dịch vụ. Theo chính sách của chúng tôi, cần đặt cọc trước 30% của giờ làm luật sư để tiến hành đặt lịch.',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoItem('Số dịch vụ:', '$serviceCount dịch vụ'),
            _buildInfoItem('Tỷ lệ đặt cọc:', '30%'),
            _buildInfoItem('Phương thức:', 'Chuyển khoản ngân hàng'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[600], size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bạn có thể chọn ít hơn $serviceCount dịch vụ để không cần đặt cọc. Đặt cọc sẽ được hoàn trả 100% nếu hủy lịch trước 24 giờ.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Chọn ít hơn'),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToLawyerSelection();
            },
            child: const Text('1 dịch vụ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToLawyerSelection();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Xác nhận đặt cọc'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _navigateToLawyerSelection() {
    context.push('/lawyer-selection', extra: {
      'services': _selectedServices.entries.map((e) => e.key).toList(),
      'field': _selectedField,
    });
  }

  Widget _buildServiceMultiSelect() {
    final items = _filteredServicesByField();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Chọn dịch vụ (có thể chọn nhiều)'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((s) {
            final name = s.name ?? '';
            final selected = _selectedServices.containsKey(name);
            return FilterChip(
              label: Text(name.isEmpty ? 'Dịch vụ' : name),
              selected: selected,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    // Nếu chọn, lưu kèm specialization để biết thuộc lĩnh vực nào
                    _selectedServices[name] = s.specialization ?? '';
                  } else {
                    _selectedServices.remove(name);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  List<ServiceModel> _filteredServicesByField() {
    if (_selectedField == null || _selectedField == ALL_FIELDS)
      return _services;
    final f = _selectedField!.toLowerCase();
    return _services
        .where((s) => (s.specialization ?? '').toLowerCase() == f)
        .toList();
  }

  Widget _buildSelectedServicesList() {
    if (_selectedServices.isEmpty) {
      return Text('Chưa chọn dịch vụ',
          style: TextStyle(color: Colors.grey[700]));
    }
    // Gom nhóm dịch vụ đã chọn theo lĩnh vực
    final Map<String, List<String>> grouped = {};
    for (final entry in _selectedServices.entries) {
      grouped.putIfAbsent(entry.value, () => []).add(entry.key);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dịch vụ đã chọn:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        ...grouped.entries.map((e) => Padding(
              padding: const EdgeInsets.only(top: 4, left: 8),
              child: Text('${e.value.join(", ")} (${e.key})',
                  style: const TextStyle(color: Colors.black87)),
            )),
        Wrap(
          spacing: 6,
          children: _selectedServices.entries
              .map((entry) => Chip(
                    label: Text('${entry.key} (${entry.value})'),
                    onDeleted: () {
                      setState(() {
                        _selectedServices.remove(entry.key);
                      });
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}

/* Service model centralized in features/services/data/models/service.dart */
/*
class Service {
  final String? id;
  final String? name;
  final String? description;
  final String? specialization;

  Service({
    this.id,
    this.name,
    this.description,
    this.specialization,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    String? pickStr(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v != null && v.toString().isNotEmpty) return v.toString();
      }
      return null;
    }

    // Lấy specialization từ practiceArea nếu có
    String? specialization;
    if (json['practiceArea'] is Map<String, dynamic>) {
      final practiceArea = json['practiceArea'] as Map<String, dynamic>;
      specialization = practiceArea['name']?.toString();
    }

    return Service(
      id: pickStr(['id', 'serviceId', 'serviceID', 'Id', 'ServiceId']),
      name: pickStr(['name', 'serviceName', 'title', 'Name']),
      description: pickStr(['description', 'desc', 'Description']),
      specialization: specialization ??
          pickStr([
            'specialization',
            'specializationName',
            'category',
            'field',
            'domain',
            'type'
          ]),
    );
  }
}
*/
