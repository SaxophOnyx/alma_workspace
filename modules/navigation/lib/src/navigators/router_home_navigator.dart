import 'package:home/home.dart';

import '../router/app_router.dart';

final class RouterHomeNavigator implements HomeNavigator {
  // ignore: unused_field - kept to demonstrate the navigator pattern
  final AppRouter _appRouter;

  const RouterHomeNavigator({
    required AppRouter appRouter,
  }) : _appRouter = appRouter;
}
