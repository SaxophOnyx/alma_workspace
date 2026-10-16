import 'package:auto_route/auto_route.dart';

import 'hablar.gr.dart';

export 'hablar.gr.dart';
export 'src/navigation/hablar_navigator.dart';

@AutoRouterConfig()
class HablarRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
    AutoRoute(
      page: HablarMainRoute.page,
    ),
    AutoRoute(
      page: HablarWordCardRoute.page,
    ),
    AutoRoute(
      page: HablarDictionaryRoute.page,
    ),
    AutoRoute(
      page: HablarQuizRoute.page,
    ),
  ];
}
