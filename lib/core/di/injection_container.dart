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
import '../../features/admin/data/services/customer_api_service.dart';
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
  
  print('✅ AdminApiService registered: ${getIt.isRegistered<AdminApiService>()}');
  print('✅ CustomerApiService registered: ${getIt.isRegistered<CustomerApiService>()}');
}
