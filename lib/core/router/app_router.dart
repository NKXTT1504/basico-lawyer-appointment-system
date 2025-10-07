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
import '../../features/profile/presentation/pages/profile_demo_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../responsive_test_page.dart';
import '../layout/main_shell.dart';
import '../../features/services/presentation/pages/services_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart'
    as admin_pages;
import '../../features/admin/presentation/pages/admin_appointments_page.dart';
import '../../features/admin/presentation/pages/admin_customers_page.dart';
import '../../features/admin/presentation/pages/admin_lawyers_page.dart';
import '../../features/admin/presentation/pages/lawyer_dashboard_page.dart'
    as lawyer_pages;
import '../../features/admin/presentation/pages/lawyer_appointments_page.dart';
import '../../features/admin/presentation/pages/lawyer_profile_page.dart';
import '../../features/admin/presentation/widgets/main_navigation.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // Root redirect for web direct hits
      GoRoute(
        path: '/',
        redirect: (_, __) => '/splash',
      ),
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

      // Admin Routes with Sidebar
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => MainNavigation(
          currentPath: '/admin/dashboard',
          child: const admin_pages.AdminDashboardPage(),
        ),
      ),
      GoRoute(
        path: '/admin/appointments',
        builder: (context, state) => MainNavigation(
          currentPath: '/admin/appointments',
          child: const AdminAppointmentsPage(),
        ),
      ),
      GoRoute(
        path: '/admin/customers',
        builder: (context, state) => MainNavigation(
          currentPath: '/admin/customers',
          child: const AdminCustomersPage(),
        ),
      ),
      GoRoute(
        path: '/admin/lawyers',
        builder: (context, state) => MainNavigation(
          currentPath: '/admin/lawyers',
          child: const AdminLawyersPage(),
        ),
      ),

      // Lawyer Routes with Sidebar
      GoRoute(
        path: '/lawyer/dashboard',
        builder: (context, state) => MainNavigation(
          currentPath: '/lawyer/dashboard',
          child: const lawyer_pages.LawyerDashboardPage(),
        ),
      ),
      GoRoute(
        path: '/lawyer/appointments',
        builder: (context, state) => MainNavigation(
          currentPath: '/lawyer/appointments',
          child: const LawyerAppointmentsPage(),
        ),
      ),
      GoRoute(
        path: '/lawyer/profile',
        builder: (context, state) => MainNavigation(
          currentPath: '/lawyer/profile',
          child: const LawyerProfilePage(),
        ),
      ),

      // Customer Routes with Sidebar (Main app)
      GoRoute(
        path: '/home',
        builder: (context, state) => MainNavigation(
          currentPath: '/home',
          child: const HomePage(),
        ),
      ),
      GoRoute(
        path: '/appointments',
        builder: (context, state) => MainNavigation(
          currentPath: '/appointments',
          child: const AppointmentListPage(),
        ),
      ),
      GoRoute(
        path: '/book-appointment',
        redirect: (context, state) => '/appointments',
      ),
      GoRoute(
        path: '/appointments/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AppointmentDetailPage(appointmentId: id);
        },
      ),
      GoRoute(
        path: '/lawyers',
        builder: (context, state) => MainNavigation(
          currentPath: '/lawyers',
          child: const LawyerListPage(),
        ),
      ),
      GoRoute(
        path: '/lawyers/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return LawyerDetailPage(lawyerId: id);
        },
      ),
      GoRoute(
        path: '/services',
        builder: (context, state) => MainNavigation(
          currentPath: '/services',
          child: const ServicesPage(),
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => MainNavigation(
          currentPath: '/profile',
          child: const ProfilePage(),
        ),
      ),
      GoRoute(
        path: '/profile-demo',
        builder: (context, state) => const ProfileDemoPage(),
      ),

      // Test Pages (Development)
      GoRoute(
        path: '/responsive-test',
        builder: (context, state) => const ResponsiveTestPage(),
      ),
    ],
  );
}
