import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/appointment/presentation/bloc/appointment_bloc.dart';
import '../../features/appointment/data/datasources/appointment_local_data_source.dart';
import '../../features/lawyer/presentation/bloc/lawyer_bloc.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/admin/data/services/admin_api_service.dart';
import '../../features/customer/data/services/customer_api_service.dart';
import '../../features/admin/di/feature_injector.dart' as admin_injector;
import '../../features/customer/di/feature_injector.dart' as customer_injector;
import '../../features/lawyer/di/feature_injector.dart' as lawyer_injector;
import '../../features/auth/di/feature_injector.dart' as auth_injector;
import '../../features/services/di/feature_injector.dart' as services_injector;
import '../../features/chat/di/feature_injector.dart' as chat_injector;
import '../network/api_client.dart';
import '../network/network_info.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // Reset GetIt to clear any previous registrations
  if (getIt.isRegistered<AdminApiService>()) {
    await getIt.reset();
  }
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());

  // Data Sources
  getIt.registerLazySingleton<AppointmentLocalDataSource>(
    () => AppointmentLocalDataSourceImpl(),
  );

  // Network
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt<Connectivity>()),
  );
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(
        getIt<Dio>(), getIt<SharedPreferences>(), getIt<NetworkInfo>()),
  );

  // Auth
  getIt.registerFactory(() => AuthBloc());

  // Appointment
  getIt.registerFactory(
      () => AppointmentBloc(dataSource: getIt<AppointmentLocalDataSource>()));

  // Lawyer
  getIt.registerFactory(() => LawyerBloc());

  // Profile
  getIt.registerFactory(() => ProfileBloc());

  // Admin Services
  getIt.registerLazySingleton<AdminApiService>(() => AdminApiService());
  getIt.registerLazySingleton<CustomerApiService>(
    () => CustomerApiService(getIt<AdminApiService>()),
  );

  print(
      '✅ AdminApiService registered: ${getIt.isRegistered<AdminApiService>()}');
  print(
      '✅ CustomerApiService registered: ${getIt.isRegistered<CustomerApiService>()}');

  // Feature-specific registrations (kept no-op if empty to preserve logic)
  admin_injector.registerAdminFeature(getIt);
  customer_injector.registerCustomerFeature(getIt);
  lawyer_injector.registerLawyerFeature(getIt);
  auth_injector.registerAuthFeature(getIt);
  services_injector.registerServicesFeature(getIt);
  chat_injector.registerChatFeature(getIt);
}
