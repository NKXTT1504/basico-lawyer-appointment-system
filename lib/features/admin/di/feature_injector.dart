import 'package:get_it/get_it.dart';
import '../data/services/admin_api_service.dart';

void registerAdminFeature(GetIt getIt) {
  if (!getIt.isRegistered<AdminApiService>()) {
    getIt.registerLazySingleton<AdminApiService>(() => AdminApiService());
  }
}
