import 'package:flutter/material.dart';

class AppointmentListPage extends StatelessWidget {
  const AppointmentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch hẹn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to create appointment
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Danh sách lịch hẹn - Sẽ được phát triển'),
      ),
    );
  }
}
