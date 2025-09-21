import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/appointment/presentation/bloc/appointment_bloc.dart';
import '../../features/lawyer/presentation/bloc/lawyer_bloc.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../di/injection_container.dart';

class AppConfig {
  static List<BlocProvider> get providers => [
    BlocProvider<AuthBloc>(
      create: (context) => getIt<AuthBloc>(),
    ),
    BlocProvider<AppointmentBloc>(
      create: (context) => getIt<AppointmentBloc>(),
    ),
    BlocProvider<LawyerBloc>(
      create: (context) => getIt<LawyerBloc>(),
    ),
    BlocProvider<ProfileBloc>(
      create: (context) => getIt<ProfileBloc>(),
    ),
  ];
}
