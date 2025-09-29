import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    
    if (location.startsWith('/home')) {
      return 0;
    } else if (location.startsWith('/appointments')) {
      return 1;
    } else if (location.startsWith('/lawyers')) {
      return 2;
    } else if (location.startsWith('/services') || location.startsWith('/profile')) {
      return 3;
    }
    
    return 0; // Default to home
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/appointments');
        break;
      case 2:
        context.go('/lawyers');
        break;
      case 3:
        // Services tab
        context.go('/services');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final currentIndex = _getCurrentIndex(context);
    
    return Scaffold(
      body: SafeArea(
        top: false,
        child: widget.child,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1E3A8A),
          unselectedItemColor: Colors.grey[600],
          selectedFontSize: screenWidth * 0.032,
          unselectedFontSize: screenWidth * 0.028,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: screenWidth * 0.05),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today, size: screenWidth * 0.05),
              label: 'Lịch hẹn',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people, size: screenWidth * 0.05),
              label: 'Luật sư',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business_center, size: screenWidth * 0.05),
              label: 'Dịch vụ',
            ),
          ],
        ),
      ),
    );
  }
}
