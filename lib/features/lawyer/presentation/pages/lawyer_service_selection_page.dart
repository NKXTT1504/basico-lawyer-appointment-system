import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/lawyer_api_service.dart';
import '../../../services/data/models/service.dart';

class LawyerServiceSelectionPage extends StatefulWidget {
  final String lawyerId;
  final String lawyerName;

  const LawyerServiceSelectionPage({
    super.key,
    required this.lawyerId,
    required this.lawyerName,
  });

  @override
  State<LawyerServiceSelectionPage> createState() =>
      _LawyerServiceSelectionPageState();
}

class _LawyerServiceSelectionPageState
    extends State<LawyerServiceSelectionPage> {
  List<ServiceModel> _services = <ServiceModel>[];
  List<String> _fields = <String>[];
  String? _selectedField;
  final Set<String> _selectedServiceNames = <String>{};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final response = await LawyerApiService.getServices();
      if (response.statusCode == 200) {
        final List<dynamic> raw = _extractList(response.data);
        final services =
            raw.map((e) => ServiceModel.fromJson(_asMap(e))).toList();

        final fields = <String>{};
        for (final s in services) {
          if (s.specialization != null && s.specialization!.isNotEmpty) {
            fields.add(s.specialization!);
          }
        }

        setState(() {
          _services = services;
          _fields = fields.toList()..sort();
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Lỗi tải dịch vụ: ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi tải dữ liệu: $e';
        _loading = false;
      });
    }
  }

  List<dynamic> _extractList(dynamic body) {
    if (body == null) return const [];
    if (body is List) return body;
    if (body is Map<String, dynamic>) {
      for (final k in [
        'result',
        'data',
        'items',
        'results',
        'value',
        r'$values',
        'list',
        'services',
        'records',
      ]) {
        final v = body[k];
        if (v is List) return v;
      }
      for (final v in body.values) {
        if (v is List) return v;
      }
    }
    return const [];
  }

  Map<String, dynamic> _asMap(dynamic e) {
    if (e is Map<String, dynamic>) return e;
    if (e is Map) return e.map((k, v) => MapEntry(k.toString(), v));
    return <String, dynamic>{};
  }

  bool get _canContinue => _selectedServiceNames.isNotEmpty;

  void _continue() {
    if (!_canContinue) return;
    context.push('/book-appointment/${widget.lawyerId}', extra: {
      'lawyerName': widget.lawyerName,
      'services': _selectedServiceNames.toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn lĩnh vực & dịch vụ'),
        elevation: 0,
        backgroundColor: Colors.blue[50],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red[300]),
                      const SizedBox(height: 12),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: _load, child: const Text('Thử lại')),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildProgress(),
                      const SizedBox(height: 24),
                      _buildForm(),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _canContinue ? _continue : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Tiếp tục'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.person, color: Color(0xFF1E3A8A)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.lawyerName,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text('Chọn lĩnh vực và dịch vụ để tiếp tục',
                  style: TextStyle(color: Colors.grey[700])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgress() {
    return Row(
      children: [
        _step(1, 'Luật sư', active: true),
        _divider(),
        _step(2, 'Lĩnh vực & Dịch vụ', active: true),
        _divider(),
        _step(3, 'Ngày & Giờ', active: false),
        _divider(),
        _step(4, 'Xác nhận', active: false),
      ],
    );
  }

  Widget _divider() => Expanded(
        child: Container(
            height: 2,
            color: Colors.grey[300],
            margin: const EdgeInsets.symmetric(horizontal: 8)),
      );

  Widget _step(int num, String title, {required bool active}) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: active ? Colors.blue[600] : Colors.grey[300],
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text('$num',
                style: TextStyle(
                    color: active ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 6),
        Text(title,
            style: TextStyle(
                fontSize: 11,
                color: active ? Colors.blue[700] : Colors.grey[600])),
      ],
    );
  }

  Widget _buildForm() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chọn lĩnh vực',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedField,
              decoration: InputDecoration(
                hintText: '-- Chọn lĩnh vực --',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: _fields
                  .map(
                      (f) => DropdownMenuItem<String>(value: f, child: Text(f)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedField = value;
                  _selectedServiceNames.clear();
                });
              },
            ),
            const SizedBox(height: 16),
            const Text('Chọn dịch vụ (có thể chọn nhiều)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _filteredServicesByField().map((s) {
                final name = s.name ?? '';
                final selected = _selectedServiceNames.contains(name);
                return FilterChip(
                  selected: selected,
                  label: Text(name.isEmpty ? 'Dịch vụ' : name),
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
        ),
      ),
    );
  }

  List<ServiceModel> _filteredServicesByField() {
    if (_selectedField == null || _selectedField!.isEmpty) return _services;
    final fieldLower = _selectedField!.toLowerCase();
    return _services
        .where(
            (s) => (s.specialization ?? '').toLowerCase().contains(fieldLower))
        .toList();
  }
}
