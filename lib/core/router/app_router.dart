import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/appointment/presentation/pages/appointment_list_page.dart';
import '../../features/appointment/presentation/pages/appointment_detail_page.dart';
import '../../features/lawyer/presentation/pages/lawyer_list_page.dart';
import '../../features/lawyer/presentation/pages/lawyer_detail_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      
      // Auth
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      
      // Main App
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      
      // Appointments
      GoRoute(
        path: '/appointments',
        builder: (context, state) => const AppointmentListPage(),
      ),
      GoRoute(
        path: '/appointments/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AppointmentDetailPage(appointmentId: id);
        },
      ),
      
      // Lawyers
      GoRoute(
        path: '/lawyers',
        builder: (context, state) => const LawyerListPage(),
      ),
      GoRoute(
        path: '/lawyers/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return LawyerDetailPage(lawyerId: id);
        },
      ),
      
      // Profile
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
}
