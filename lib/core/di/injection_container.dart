import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/appointment/presentation/bloc/appointment_bloc.dart';
import '../../features/appointment/data/datasources/appointment_local_data_source.dart';
import '../../features/lawyer/presentation/bloc/lawyer_bloc.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
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
}
