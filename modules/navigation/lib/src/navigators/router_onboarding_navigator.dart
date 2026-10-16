import 'package:auto_route/auto_route.dart';
import 'package:home/home.dart';
import 'package:onboarding/onboarding.dart';

import '../router/app_router.dart';

final class RouterOnboardingNavigator implements OnboardingNavigator {
  final AppRouter _appRouter;

  const RouterOnboardingNavigator({
    required AppRouter appRouter,
  }) : _appRouter = appRouter;

  @override
  Future<void> openHome() {
    return _appRouter.replaceAll(
      <PageRouteInfo>[const HomeRoute()],
      updateExistingRoutes: false,
    );
  }
}
