import 'package:flutter/material.dart';

class FeatureCards extends StatelessWidget {
  const FeatureCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 80),
      child: Row(
        children: [
          Expanded(
            child: _buildFeatureCard(
              'Luật sư giàu kinh nghiệm',
              'Luật sư của chúng tôi có trung bình hơn 10 năm kinh nghiệm trong lĩnh vực chuyên môn của họ.',
              Icons.people,
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: _buildFeatureCard(
              'Giải Pháp Cá Nhân Hóa',
              'Chiến lược pháp lý được thiết kế riêng để phù hợp với nhu cầu cụ thể của bạn.',
              Icons.person_pin,
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: _buildFeatureCard(
              'Tập Trung Vào Khách Hàng',
              'Chúng tôi ưu tiên sự giao tiếp rõ ràng và dịch vụ xuất sắc.',
              Icons.favorite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1E3A8A),
              size: 36,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
