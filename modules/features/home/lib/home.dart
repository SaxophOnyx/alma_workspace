import 'package:auto_route/auto_route.dart';

import 'home.gr.dart';

export 'home.gr.dart';
export 'src/navigation/home_navigator.dart';

@AutoRouterConfig()
class HomeRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
    AutoRoute(
      page: HomeRoute.page,
    ),
  ];
}
