import 'package:flutter/material.dart';

class LawyerDetailPage extends StatelessWidget {
  final String lawyerId;

  const LawyerDetailPage({
    super.key,
    required this.lawyerId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết luật sư'),
      ),
      body: Center(
        child: Text('Chi tiết luật sư $lawyerId - Sẽ được phát triển'),
      ),
    );
  }
}
