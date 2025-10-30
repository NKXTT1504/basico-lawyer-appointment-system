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
  final Set<String> _selectedServiceNames = <String>{};
  bool _isLoading = true;
  String? _error;

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

      // Load services
      final servicesResponse = await LawyerApiService.getServices();
      if (servicesResponse.statusCode == 200) {
        final List<dynamic> data = _extractList(servicesResponse.data);
        final services =
            data.map((e) => ServiceModel.fromJson(_asMap(e))).toList();

        // Extract unique fields from services
        final fields = <String>{};
        for (final service in services) {
          if (service.specialization != null) {
            fields.add(service.specialization!);
          }
        }

        setState(() {
          _services = services;
          _fields = fields.toList()..sort();
          _isLoading = false;
        });

        // Set preselected service if provided
        if (widget.preselectedService != null) {
          _selectedField = widget.preselectedService!.specialization;
          final name = widget.preselectedService!.name;
          if (name != null && name.isNotEmpty) {
            _selectedServiceNames.add(name);
          }
        }
      } else {
        setState(() {
          _error = 'Lỗi tải dịch vụ: ${servicesResponse.statusCode}';
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
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          _buildProgressIndicator(),

          const SizedBox(height: 32),

          // Main form
          Card(
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
                    'Chọn dịch vụ & lĩnh vực',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Service dropdown
                  // Multi-select services using chips
                  _buildServiceMultiSelect(),

                  const SizedBox(height: 20),

                  // Field dropdown
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

                  const SizedBox(height: 32),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canContinue() ? _continue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Tiếp tục',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Benefits section
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

  bool _canContinue() {
    return _selectedServiceNames.isNotEmpty;
  }

  void _continue() {
    // Chuyển đến trang chọn luật sư với danh sách dịch vụ đã chọn
    context.push('/lawyer-selection', extra: {
      'services': _selectedServiceNames.toList(),
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
            final selected = _selectedServiceNames.contains(name);
            return FilterChip(
              label: Text(name.isEmpty ? 'Dịch vụ' : name),
              selected: selected,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _selectedServiceNames.add(name);
                  } else {
                    _selectedServiceNames.remove(name);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedServiceNames.isEmpty
              ? 'Chưa chọn dịch vụ'
              : 'Đã chọn: ${_selectedServiceNames.join(', ')}',
          style: TextStyle(color: Colors.grey[700]),
        ),
      ],
    );
  }

  List<ServiceModel> _filteredServicesByField() {
    if (_selectedField == null || _selectedField!.isEmpty) return _services;
    final f = _selectedField!.toLowerCase();
    return _services
        .where((s) => (s.specialization ?? '').toLowerCase().contains(f))
        .toList();
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
