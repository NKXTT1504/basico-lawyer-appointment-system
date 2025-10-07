import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../admin/data/services/user_storage_service.dart';
import '../../../admin/data/models/admin_user.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    try {
      final user = await UserStorageService.getCurrentUser();
      if (!mounted) return;
      if (user == null) {
        context.go('/login');
        return;
      }
      switch (user.role) {
        case UserRole.admin:
          context.go('/admin/dashboard');
          break;
        case UserRole.lawyer:
          context.go('/lawyer/dashboard');
          break;
        case UserRole.customer:
          context.go('/home');
          break;
      }
    } catch (e) {
      if (!mounted) return;
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.gavel,
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Basico Lawyer',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Đặt lịch tư vấn pháp lý',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
