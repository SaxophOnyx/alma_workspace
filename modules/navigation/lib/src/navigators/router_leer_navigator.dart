import 'package:auto_route/auto_route.dart';
import 'package:domain/domain.dart';
import 'package:flutter/widgets.dart';
import 'package:leer/leer.dart';
import 'package:respirar/respirar.dart';

import '../router/app_router.dart';

final class RouterLeerNavigator implements LeerNavigator {
  final AppRouter _appRouter;

  static final Set<String> _leerRouteNames = LeerRouter().routes.map((AutoRoute route) => route.name).toSet();

  const RouterLeerNavigator({
    required AppRouter appRouter,
  }) : _appRouter = appRouter;

  @override
  Future<void> openContext(String textId) {
    return _appRouter.push(LeerContextRoute(textId: textId));
  }

  @override
  Future<void> startReading(String textId) {
    return _appRouter.push(LeerReadingRoute(textId: textId));
  }

  @override
  Future<void> openWordAnnotation(String wordId) {
    return _appRouter.push<void>(LeerWordAnnotationRoute(wordId: wordId));
  }

  @override
  Future<void> closeWordAnnotation() async {
    _appRouter.pop();
  }

  @override
  Future<void> openTextList() async {
    final bool hasTextList = _appRouter.stackData.any((RouteData<dynamic> data) => data.name == LeerTextListRoute.name);
    if (hasTextList) {
      _appRouter.popUntilRouteWithName(LeerTextListRoute.name);
      return;
    }

    // Leer was entered from another module straight into a text: swap the Leer screens for the list.
    _appRouter.popUntil((Route<dynamic> route) => !_leerRouteNames.contains(route.settings.name));
    await _appRouter.push<void>(const LeerTextListRoute());
  }

  @override
  Future<void> breatheWithText() {
    return _appRouter.push(RespirarDurationRoute(mode: BreathingMode.abrazo));
  }

  @override
  Future<void> openHome() async {
    _appRouter.popUntilRoot();
  }

  @override
  Future<void> back() {
    return _appRouter.maybePop();
  }
}
