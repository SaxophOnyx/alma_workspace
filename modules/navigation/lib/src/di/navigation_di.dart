import 'package:core/core.dart';
import 'package:home/home.dart';
import 'package:launch/launch.dart';
import 'package:leer/leer.dart';
import 'package:onboarding/onboarding.dart';
import 'package:respirar/respirar.dart';

import '../navigators/navigators.dart';
import '../router/app_router.dart';

final class NavigationDI {
  const NavigationDI._();

  static void initDependencies(GetIt locator) {
    _initRouter(locator);
    _initNavigators(locator);
  }

  static void _initRouter(GetIt locator) {
    locator.registerSingleton(AppRouter());
  }

  static void _initNavigators(GetIt locator) {
    locator.registerLazySingleton<HomeNavigator>(
      () => RouterHomeNavigator(appRouter: locator<AppRouter>()),
    );
    locator.registerLazySingleton<LaunchNavigator>(
      () => RouterLaunchNavigator(appRouter: locator<AppRouter>()),
    );
    locator.registerLazySingleton<OnboardingNavigator>(
      () => RouterOnboardingNavigator(appRouter: locator<AppRouter>()),
    );
    locator.registerLazySingleton<RespirarNavigator>(
      () => RouterRespirarNavigator(appRouter: locator<AppRouter>()),
    );
    locator.registerLazySingleton<LeerNavigator>(
      () => RouterLeerNavigator(appRouter: locator<AppRouter>()),
    );
  }
}
