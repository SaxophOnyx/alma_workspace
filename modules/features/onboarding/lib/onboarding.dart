import 'package:auto_route/auto_route.dart';

import 'onboarding.gr.dart';

export 'onboarding.gr.dart';
export 'src/navigation/onboarding_navigator.dart';

@AutoRouterConfig()
class OnboardingRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
    AutoRoute(
      page: OnboardingRoute.page,
    ),
  ];
}
