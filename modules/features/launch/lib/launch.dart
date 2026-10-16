import 'package:auto_route/auto_route.dart';

import 'launch.gr.dart';

export 'launch.gr.dart';
export 'src/navigation/launch_navigator.dart';

@AutoRouterConfig()
class LaunchRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
    AutoRoute(
      initial: true,
      page: LaunchRoute.page,
    ),
  ];
}
