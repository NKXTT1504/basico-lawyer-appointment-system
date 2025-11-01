import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/appointment/presentation/pages/appointment_list_page.dart';
import '../../features/appointment/presentation/pages/appointment_detail_page.dart';
import '../../features/lawyer/presentation/pages/lawyer_list_page.dart';
import '../../features/lawyer/presentation/pages/lawyer_detail_page.dart';
import '../../features/lawyer/presentation/pages/lawyer_service_selection_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/profile_demo_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../responsive_test_page.dart';
import '../../features/services/presentation/pages/services_page.dart';
import '../../features/services/presentation/pages/service_selection_page.dart';
import '../../features/services/presentation/pages/lawyer_selection_page.dart';
import '../../features/services/presentation/pages/service_detail_page.dart';
import '../../features/services/presentation/pages/service_field_selection_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/appointment/presentation/pages/payment_return_page.dart';
import '../../features/admin/data/services/user_storage_service.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart'
    as admin_pages;
import '../../features/admin/presentation/pages/admin_appointments_page.dart';
import '../../features/admin/presentation/pages/admin_customers_page.dart';
import '../../features/admin/presentation/pages/admin_lawyers_page.dart';
import '../../features/admin/presentation/pages/admin_forms_page.dart';
import '../../features/admin/presentation/pages/lawyer_dashboard_page.dart'
    as lawyer_pages;
import '../../features/admin/presentation/pages/lawyer_appointments_page.dart';
import '../../features/admin/presentation/pages/lawyer_profile_page.dart';
import '../../features/admin/presentation/widgets/main_navigation.dart';
import '../../features/admin/data/models/admin_user.dart' show UserRole;

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
      GoRoute(
        path: '/admin/forms',
        builder: (context, state) => MainNavigation(
          currentPath: '/admin/forms',
          child: const AdminFormsPage(),
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
        redirect: (context, state) async {
          // Require login and completed profile for customers before viewing appointments
          final loggedIn = await UserStorageService.isLoggedIn();
          if (!loggedIn) return '/login';
          final role = await UserStorageService.getCurrentUserRole();
          if (role == UserRole.customer) {
            final complete =
                await UserStorageService.isProfileCompleteForCurrentUser();
            if (!complete) return '/profile';
          }
          return null;
        },
        builder: (context, state) => MainNavigation(
          currentPath: '/appointments',
          child: const AppointmentListPage(),
        ),
      ),
      GoRoute(
        path: '/book-appointment/:lawyerId',
        redirect: (context, state) async {
          final loggedIn = await UserStorageService.isLoggedIn();
          if (!loggedIn) return '/login';
          final role = await UserStorageService.getCurrentUserRole();
          if (role == UserRole.customer) {
            final complete =
                await UserStorageService.isProfileCompleteForCurrentUser();
            if (!complete) return '/profile';
          }
          return null;
        },
        builder: (context, state) {
          final lawyerId = state.pathParameters['lawyerId']!;
          final extra = (state.extra as Map<String, dynamic>?) ?? {};
          final lawyerName = (extra['lawyerName'] as String?) ?? 'Luật sư';
          final services = (extra['services'] as List<String>?) ?? <String>[];
          return MainNavigation(
            currentPath: '/appointments',
            child: BookingPage(
              lawyerId: lawyerId,
              lawyerName: lawyerName,
              services: services,
            ),
          );
        },
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
        redirect: (context, state) async {
          // Must be logged in to see lawyers list
          final loggedIn = await UserStorageService.isLoggedIn();
          if (!loggedIn) return '/login';
          return null;
        },
        builder: (context, state) => MainNavigation(
          currentPath: '/lawyers',
          child: const LawyerListPage(),
        ),
      ),
      GoRoute(
        path: '/lawyer/:lawyerId/service-selection',
        redirect: (context, state) async {
          final loggedIn = await UserStorageService.isLoggedIn();
          if (!loggedIn) return '/login';
          final role = await UserStorageService.getCurrentUserRole();
          if (role == UserRole.customer) {
            final complete =
                await UserStorageService.isProfileCompleteForCurrentUser();
            if (!complete) return '/profile';
          }
          return null;
        },
        builder: (context, state) {
          final lawyerId = state.pathParameters['lawyerId']!;
          final lawyerName = (state.extra
                  as Map<String, dynamic>?)?['lawyerName'] as String? ??
              'Luật sư';
          return MainNavigation(
            currentPath: '/lawyers',
            child: LawyerServiceSelectionPage(
              lawyerId: lawyerId,
              lawyerName: lawyerName,
            ),
          );
        },
      ),
      GoRoute(
        path: '/book-appointment/:lawyerId/:lawyerName/:service',
        redirect: (context, state) async {
          final loggedIn = await UserStorageService.isLoggedIn();
          if (!loggedIn) return '/login';
          final role = await UserStorageService.getCurrentUserRole();
          if (role == UserRole.customer) {
            final complete =
                await UserStorageService.isProfileCompleteForCurrentUser();
            if (!complete) return '/profile';
          }
          return null;
        },
        builder: (context, state) => MainNavigation(
          currentPath: '/appointments',
          child: BookingPage(
            lawyerId: state.pathParameters['lawyerId']!,
            lawyerName: state.pathParameters['lawyerName']!,
            services: [state.pathParameters['service']!],
          ),
        ),
      ),
      // Backward-compat catch-all: any legacy deep-link like /book-appointment/:lawyerId/anything...
      GoRoute(
        path: '/book-appointment/:lawyerId/:rest(.*)',
        redirect: (context, state) async {
          final loggedIn = await UserStorageService.isLoggedIn();
          if (!loggedIn) return '/login';
          final role = await UserStorageService.getCurrentUserRole();
          if (role == UserRole.customer) {
            final complete =
                await UserStorageService.isProfileCompleteForCurrentUser();
            if (!complete) return '/profile';
          }
          return null;
        },
        builder: (context, state) {
          final lawyerId = state.pathParameters['lawyerId']!;
          final rest = state.pathParameters['rest'] ?? '';
          // try to recover [lawyerName, service] from rest
          final parts = rest.split('/').where((e) => e.isNotEmpty).toList();
          final decodedParts = parts.map(Uri.decodeComponent).toList();
          final lawyerName =
              decodedParts.isNotEmpty ? decodedParts[0] : 'Luật sư';
          final services =
              decodedParts.length >= 2 ? <String>[decodedParts[1]] : <String>[];
          return MainNavigation(
            currentPath: '/appointments',
            child: BookingPage(
              lawyerId: lawyerId,
              lawyerName: lawyerName,
              services: services,
            ),
          );
        },
      ),
      GoRoute(
        path: '/lawyers/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return LawyerDetailPage(lawyerId: id);
        },
      ),
      GoRoute(
        path: '/lawyer/:id/detail',
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
        path: '/service-selection',
        redirect: (context, state) async {
          final loggedIn = await UserStorageService.isLoggedIn();
          if (!loggedIn) return '/login';
          return null;
        },
        builder: (context, state) => MainNavigation(
          currentPath: '/service-selection',
          child: const ServiceSelectionPage(),
        ),
      ),
      GoRoute(
        path: '/service-detail',
        redirect: (context, state) async {
          final loggedIn = await UserStorageService.isLoggedIn();
          if (!loggedIn) return '/login';
          return null;
        },
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          if (data == null || data['service'] == null) {
            return MainNavigation(
              currentPath: '/services',
              child: const ServicesPage(),
            );
          }
          return ServiceDetailPage(service: data['service']);
        },
      ),
      GoRoute(
        path: '/service-field-selection',
        redirect: (context, state) async {
          final loggedIn = await UserStorageService.isLoggedIn();
          if (!loggedIn) return '/login';
          return null;
        },
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          return MainNavigation(
            currentPath: '/service-field-selection',
            child: ServiceFieldSelectionPage(
              preselectedService: data?['service'],
            ),
          );
        },
      ),
      GoRoute(
        path: '/lawyer-selection',
        redirect: (context, state) async {
          final loggedIn = await UserStorageService.isLoggedIn();
          if (!loggedIn) return '/login';
          return null;
        },
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          if (data == null ||
              (data['services'] == null && data['service'] == null)) {
            return MainNavigation(
              currentPath: '/service-selection',
              child: const ServiceSelectionPage(),
            );
          }
          // Backward compatibility: allow single 'service' or new 'services'
          final services = (data['services'] as List<String>?) ??
              (data['service'] != null
                  ? <String>[data['service'].name ?? data['service'].toString()]
                  : <String>[]);
          final field = data['field'] as String?;
          return MainNavigation(
            currentPath: '/lawyer-selection',
            child: LawyerSelectionPage(services: services, field: field),
          );
        },
      ),
      GoRoute(
        path: '/chat',
        redirect: (context, state) async {
          final loggedIn = await UserStorageService.isLoggedIn();
          if (!loggedIn) return '/login';
          return null;
        },
        builder: (context, state) => MainNavigation(
          currentPath: '/chat',
          child: const ChatPage(),
        ),
      ),
      GoRoute(
        path: '/profile',
        redirect: (context, state) async {
          final loggedIn = await UserStorageService.isLoggedIn();
          if (!loggedIn) return '/login';
          return null;
        },
        builder: (context, state) => MainNavigation(
          currentPath: '/profile',
          child: const ProfilePage(readOnly: true),
        ),
      ),
      GoRoute(
        path: '/profile/edit',
        redirect: (context, state) async {
          final loggedIn = await UserStorageService.isLoggedIn();
          if (!loggedIn) return '/login';
          return null;
        },
        builder: (context, state) => MainNavigation(
          currentPath: '/profile',
          child: const ProfilePage(readOnly: false),
        ),
      ),
      GoRoute(
        path: '/profile-demo',
        builder: (context, state) => const ProfileDemoPage(),
      ),

      // Payment Return Handler
      GoRoute(
        path: '/payment-return',
        builder: (context, state) {
          // Extract query params from URL
          final uri = Uri.base;
          final params = <String, String>{};
          uri.queryParameters.forEach((key, value) {
            params[key] = value;
          });
          return PaymentReturnPage(queryParams: params);
        },
      ),

      // Test Pages (Development)
      GoRoute(
        path: '/responsive-test',
        builder: (context, state) => const ResponsiveTestPage(),
      ),
    ],
  );
}
