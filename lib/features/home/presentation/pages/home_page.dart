import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../widgets/header_widget.dart';
import '../widgets/hero_section.dart';
import '../widgets/feature_cards.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomeTab(),
    const _AppointmentsTab(),
    const _LawyersTab(),
    const _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1E3A8A),
          unselectedItemColor: Colors.grey[600],
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 20.sp),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today, size: 20.sp),
              label: 'Lịch hẹn',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people, size: 20.sp),
              label: 'Luật sư',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 20.sp),
              label: 'Cá nhân',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderWidget(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const HeroSection(),
              const FeatureCards(),
              // Footer section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                color: const Color(0xFF1E3A8A),
                child: Column(
                  children: [
                    Text(
                      'BASICO LAW FIRM',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Giải pháp pháp lý chuyên nghiệp cho mọi nhu cầu',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      '© 2024 Basico Law Firm. Tất cả quyền được bảo lưu.',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.white60,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppointmentsTab extends StatelessWidget {
  const _AppointmentsTab();

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

class _LawyersTab extends StatelessWidget {
  const _LawyersTab();

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

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cá nhân'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Thông tin cá nhân - Sẽ được phát triển'),
      ),
    );
  }
}
