import 'package:auto_route/auto_route.dart';
import 'package:shared_ui/shared_ui.dart';

import 'respirar.gr.dart';

export 'respirar.gr.dart';
export 'src/navigation/respirar_navigator.dart';

@AutoRouterConfig()
class RespirarRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
    AutoRoute(
      page: RespirarModesRoute.page,
    ),
    AutoRoute(
      page: RespirarDurationRoute.page,
    ),
    AutoRoute(
      page: RespirarSessionRoute.page,
    ),
    CustomRoute<bool>(
      page: RespirarLeaveConfirmationRoute.page,
      opaque: false,
      customRouteBuilder: AppPageTransitions.overlay,
    ),
    AutoRoute(
      page: RespirarSessionEndRoute.page,
    ),
  ];
}
