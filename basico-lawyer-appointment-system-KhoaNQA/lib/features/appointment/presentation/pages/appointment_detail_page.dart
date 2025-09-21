import 'package:flutter/material.dart';

class AppointmentDetailPage extends StatelessWidget {
  final String appointmentId;

  const AppointmentDetailPage({
    super.key,
    required this.appointmentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết lịch hẹn'),
      ),
      body: Center(
        child: Text('Chi tiết lịch hẹn $appointmentId - Sẽ được phát triển'),
      ),
    );
  }
}
