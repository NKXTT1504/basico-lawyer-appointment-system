import 'package:flutter/material.dart';

class AdminStatusBadge extends StatelessWidget {
  final bool active;
  final String activeText;
  final String inactiveText;
  const AdminStatusBadge(
      {super.key,
      required this.active,
      this.activeText = 'Hoạt động',
      this.inactiveText = 'Không hoạt động'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE7F6EC) : const Color(0xFFFCE8E8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        active ? activeText : inactiveText,
        style: TextStyle(
          color: active ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class AdminInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const AdminInfoChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class AdminPrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  const AdminPrimaryButton(
      {super.key, required this.onPressed, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.edit, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class AdminSectionTitle extends StatelessWidget {
  final String title;
  const AdminSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
            fontSize: isMobile ? 18 : 20,
          ),
    );
  }
}

