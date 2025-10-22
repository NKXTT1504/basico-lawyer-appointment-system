import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/config/app_config.dart';
import 'core/constants/app_constants.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/data/services/user_storage_service.dart';
import 'core/firebase/firebase_init.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize Firebase (for Storage images)
  await FirebaseInitializer.ensureInitialized();

  // Initialize dependency injection
  await initializeDependencies();

  // Initialize sample data including admin account
  await UserStorageService.initializeSampleData();

  runApp(const BasicoLawyerApp());
}

class BasicoLawyerApp extends StatelessWidget {
  const BasicoLawyerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: AppConfig.providers,
          child: MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: AppRouter.router,
            builder: (context, child) {
              // Responsive design for web
              return LayoutBuilder(
                builder: (context, constraints) {
                  // If screen width is larger than mobile, center the content
                  if (constraints.maxWidth > 600) {
                    return Center(
                      child: Container(
                        width: 375,
                        height: constraints.maxHeight,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: child,
                      ),
                    );
                  }
                  return child!;
                },
              );
            },
          ),
        );
      },
    );
  }
}
