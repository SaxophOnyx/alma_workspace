import 'package:auto_route/auto_route.dart';
import 'package:home/home.dart';
import 'package:launch/launch.dart';
import 'package:onboarding/onboarding.dart';

import '../router/app_router.dart';

final class RouterLaunchNavigator implements LaunchNavigator {
  final AppRouter _appRouter;

  const RouterLaunchNavigator({
    required AppRouter appRouter,
  }) : _appRouter = appRouter;

  @override
  Future<void> openOnboarding() {
    return _appRouter.replaceAll(
      <PageRouteInfo>[const OnboardingRoute()],
      updateExistingRoutes: false,
    );
  }

  @override
  Future<void> openHome() {
    return _appRouter.replaceAll(
      <PageRouteInfo>[const HomeRoute()],
      updateExistingRoutes: false,
    );
  }
}
