import 'package:home/home.dart';
import 'package:leer/leer.dart';
import 'package:respirar/respirar.dart';

import '../router/app_router.dart';

final class RouterHomeNavigator implements HomeNavigator {
  final AppRouter _appRouter;

  const RouterHomeNavigator({
    required AppRouter appRouter,
  }) : _appRouter = appRouter;

  @override
  Future<void> openRespirar() {
    return _appRouter.push(const RespirarModesRoute());
  }

  @override
  Future<void> openHablar() async {
    // TODO(hablar): open the Hablar module once it exists.
  }

  @override
  Future<void> openLeer() {
    return _appRouter.push(const LeerTextListRoute());
  }
}
