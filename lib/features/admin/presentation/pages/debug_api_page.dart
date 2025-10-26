import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../data/services/admin_api_service.dart';
import '../../data/services/customer_api_service.dart';

class DebugApiPage extends StatefulWidget {
  const DebugApiPage({super.key});

  @override
  State<DebugApiPage> createState() => _DebugApiPageState();
}

class _DebugApiPageState extends State<DebugApiPage> {
  final List<String> _logs = [];
  bool _isLoading = false;

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
  }

  Future<void> _testCustomersApi() async {
    setState(() => _isLoading = true);
    _addLog('🔄 Testing Customers API...');

    try {
      final customerApiService = GetIt.instance<CustomerApiService>();
      final customers = await customerApiService.fetchCustomersFromApi();
      _addLog('✅ Customers API Success: Found ${customers.length} customers');
    } catch (e) {
      _addLog('❌ Customers API Error: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _testAppointmentsApi() async {
    setState(() => _isLoading = true);
    _addLog('🔄 Testing Appointments API...');

    try {
      final adminApiService = GetIt.instance<AdminApiService>();
      final response = await adminApiService.getAppointmentsJoined();
      _addLog('✅ Appointments API Success: ${response.statusCode}');
      _addLog('📄 Response data: ${response.data}');
    } catch (e) {
      _addLog('❌ Appointments API Error: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _testLawyersApi() async {
    setState(() => _isLoading = true);
    _addLog('🔄 Testing Lawyers API...');

    try {
      final adminApiService = GetIt.instance<AdminApiService>();
      final response = await adminApiService.getAllLawyersProfile();
      _addLog('✅ Lawyers API Success: ${response.statusCode}');
      _addLog('📄 Response data: ${response.data}');
    } catch (e) {
      _addLog('❌ Lawyers API Error: $e');
    }

    setState(() => _isLoading = false);
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Debug'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Test buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _testCustomersApi,
                        child: const Text('Test Customers API'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _testAppointmentsApi,
                        child: const Text('Test Appointments API'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _testLawyersApi,
                        child: const Text('Test Lawyers API'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _clearLogs,
                        child: const Text('Clear Logs'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Loading indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),

          // Logs
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      log,
                      style: const TextStyle(
                        color: Colors.green,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
