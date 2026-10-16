import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import 'leer.gr.dart';

export 'leer.gr.dart';
export 'src/navigation/leer_navigator.dart';

@AutoRouterConfig()
class LeerRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
    AutoRoute(
      page: LeerTextListRoute.page,
    ),
    AutoRoute(
      page: LeerContextRoute.page,
    ),
    AutoRoute(
      page: LeerReadingRoute.page,
    ),
    CustomRoute<void>(
      page: LeerWordAnnotationRoute.page,
      opaque: false,
      barrierColor: Colors.transparent,
      transitionsBuilder: AppPageTransitions.fade,
      duration: AppMotions.durationHighlight,
      reverseDuration: AppMotions.durationHighlight,
    ),
  ];
}
