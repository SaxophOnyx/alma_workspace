import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/providers.dart';
import '../repositories/repositories.dart';

final class DataDI {
  const DataDI._();

  static void initDependencies(GetIt locator) {
    _initProviders(locator);
    _initRepositories(locator);
  }

  static void _initProviders(GetIt locator) {
    locator.registerLazySingleton<LocalStorageProvider>(
      () => SharedPreferencesLocalStorageProvider(
        preferences: SharedPreferencesAsync(),
      ),
    );
  }

  static void _initRepositories(GetIt locator) {
    locator.registerLazySingleton<OnboardingRepository>(
      () => LocalOnboardingRepository(
        localStorageProvider: locator<LocalStorageProvider>(),
      ),
    );
  }
}
