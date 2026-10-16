import 'package:auto_route/auto_route.dart';
import 'package:home/home.dart';
import 'package:launch/launch.dart';
import 'package:onboarding/onboarding.dart';
import 'package:shared_ui/shared_ui.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.custom(
    transitionsBuilder: AppPageTransitions.fade,
    duration: AppMotions.durationMedium,
    reverseDuration: AppMotions.durationMedium,
  );

  @override
  List<AutoRoute> get routes => <AutoRoute>[
    ...LaunchRouter().routes,
    ...OnboardingRouter().routes,
    ...HomeRouter().routes,
  ];
}
