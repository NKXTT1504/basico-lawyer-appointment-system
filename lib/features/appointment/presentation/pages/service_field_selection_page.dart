import 'package:flutter/material.dart';

class ServiceFieldSelectionPage extends StatefulWidget {
  const ServiceFieldSelectionPage({Key? key}) : super(key: key);

  @override
  State<ServiceFieldSelectionPage> createState() =>
      _ServiceFieldSelectionPageState();
}

class _ServiceFieldSelectionPageState extends State<ServiceFieldSelectionPage> {
  // Mock data cho lĩnh vực và dịch vụ
  final List<String> _fields = [
    'Hôn nhân',
    'Dân sự',
    'Hình sự',
    'Đất đai',
    'Doanh nghiệp',
    'Thuế',
    'Khác',
  ];
  final List<String> _services = [
    'Tư vấn',
    'Soạn thảo hợp đồng',
    'Bào chữa',
    'Đại diện pháp luật',
    'Tranh tụng',
    'Đàm phán',
  ];

  final Set<String> _selectedFields = {};
  final Set<String> _selectedServices = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn lĩnh vực & dịch vụ')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chọn lĩnh vực:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Wrap(
              spacing: 10,
              children: _fields
                  .map((e) => FilterChip(
                        label: Text(e),
                        selected: _selectedFields.contains(e),
                        onSelected: (selected) => setState(() {
                          if (selected) {
                            _selectedFields.add(e);
                          } else {
                            _selectedFields.remove(e);
                          }
                        }),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            const Text('Chọn dịch vụ:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Wrap(
              spacing: 10,
              children: _services
                  .map((e) => FilterChip(
                        label: Text(e),
                        selected: _selectedServices.contains(e),
                        onSelected: (selected) => setState(() {
                          if (selected) {
                            _selectedServices.add(e);
                          } else {
                            _selectedServices.remove(e);
                          }
                        }),
                      ))
                  .toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _selectedFields.isNotEmpty && _selectedServices.isNotEmpty
                        ? () {
                            Navigator.of(context).pop({
                              'fields': _selectedFields.toList(),
                              'services': _selectedServices.toList(),
                            });
                          }
                        : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Tiếp tục'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
