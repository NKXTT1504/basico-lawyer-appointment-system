import 'package:flutter/material.dart';

class LawyerListPage extends StatelessWidget {
  const LawyerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Luật sư'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Handle search
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Danh sách luật sư - Sẽ được phát triển'),
      ),
    );
  }
}
