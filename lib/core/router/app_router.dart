import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/appointment/presentation/pages/appointment_list_page.dart';
import '../../features/appointment/presentation/pages/appointment_detail_page.dart';
import '../../features/lawyer/presentation/pages/lawyer_list_page.dart';
import '../../features/lawyer/presentation/pages/lawyer_detail_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_appointments_page.dart';
import '../../features/admin/presentation/pages/admin_customers_page.dart';
import '../../features/admin/presentation/pages/admin_lawyers_page.dart';
import '../../features/admin/presentation/pages/lawyer_dashboard_page.dart';
import '../../features/admin/presentation/pages/lawyer_appointments_page.dart';
import '../../features/admin/presentation/pages/lawyer_profile_page.dart';
import '../../features/admin/presentation/widgets/main_navigation.dart';

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

      // Admin Routes with Sidebar
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => MainNavigation(
          currentPath: '/admin/dashboard',
          child: const AdminDashboardPage(),
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
          child: const LawyerDashboardPage(),
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

      // Customer Routes with Sidebar
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
        path: '/lawyers',
        builder: (context, state) => MainNavigation(
          currentPath: '/lawyers',
          child: const LawyerListPage(),
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => MainNavigation(
          currentPath: '/profile',
          child: const ProfilePage(),
        ),
      ),
    ],
  );
}
