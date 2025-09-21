import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/appointment/presentation/bloc/appointment_bloc.dart';
import '../../features/lawyer/presentation/bloc/lawyer_bloc.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
  
  // Auth
  getIt.registerFactory(() => AuthBloc());
  
  // Appointment
  getIt.registerFactory(() => AppointmentBloc());
  
  // Lawyer
  getIt.registerFactory(() => LawyerBloc());
  
  // Profile
  getIt.registerFactory(() => ProfileBloc());
}
