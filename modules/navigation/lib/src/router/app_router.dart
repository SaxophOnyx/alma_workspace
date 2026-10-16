import 'package:auto_route/auto_route.dart';
import 'package:hablar/hablar.dart';
import 'package:home/home.dart';
import 'package:launch/launch.dart';
import 'package:leer/leer.dart';
import 'package:onboarding/onboarding.dart';
import 'package:respirar/respirar.dart';
import 'package:shared_ui/shared_ui.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.custom(
    transitionsBuilder: AppPageTransitions.fadeThrough,
    duration: AppMotions.durationMedium,
    reverseDuration: AppMotions.durationMedium,
  );

  @override
  List<AutoRoute> get routes => <AutoRoute>[
    ...LaunchRouter().routes,
    ...OnboardingRouter().routes,
    ...HomeRouter().routes,
    ...RespirarRouter().routes,
    ...HablarRouter().routes,
    ...LeerRouter().routes,
  ];
}
