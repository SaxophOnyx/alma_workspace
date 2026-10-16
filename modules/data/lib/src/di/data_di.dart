import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/providers.dart';
import '../repositories/repositories.dart';
import '../services/services.dart';

final class DataDI {
  const DataDI._();

  static void initDependencies(GetIt locator) {
    _initProviders(locator);
    _initRepositories(locator);
    _initServices(locator);
  }

  static void _initProviders(GetIt locator) {
    locator.registerLazySingleton<LocalStorageProvider>(
      () => SharedPreferencesLocalStorageProvider(
        preferences: SharedPreferencesAsync(),
      ),
    );
    locator.registerLazySingleton<ContentProvider>(
      () => AssetContentProvider(bundle: rootBundle),
    );
  }

  static void _initRepositories(GetIt locator) {
    locator.registerLazySingleton<OnboardingRepository>(
      () => LocalOnboardingRepository(
        localStorageProvider: locator<LocalStorageProvider>(),
      ),
    );
    locator.registerLazySingleton<BreathingPatternRepository>(
      () => LocalBreathingPatternRepository(
        contentProvider: locator<ContentProvider>(),
      ),
    );
    locator.registerLazySingleton<QuoteRepository>(
      () => LocalQuoteRepository(
        contentProvider: locator<ContentProvider>(),
      ),
    );
  }

  static void _initServices(GetIt locator) {
    locator.registerLazySingleton<HapticFeedbackService>(
      () => const PlatformHapticFeedbackService(),
    );
    locator.registerLazySingleton<ScreenAwakeService>(
      () => const WakelockScreenAwakeService(),
    );
  }
}
