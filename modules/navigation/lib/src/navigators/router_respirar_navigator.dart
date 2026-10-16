import 'package:auto_route/auto_route.dart';
import 'package:domain/domain.dart';
import 'package:flutter/widgets.dart';
import 'package:respirar/respirar.dart';

import '../router/app_router.dart';

final class RouterRespirarNavigator implements RespirarNavigator {
  final AppRouter _appRouter;

  static final Set<String> _respirarRouteNames = RespirarRouter().routes.map((AutoRoute route) => route.name).toSet();

  const RouterRespirarNavigator({
    required AppRouter appRouter,
  }) : _appRouter = appRouter;

  @override
  Future<void> openDurationSelection(BreathingMode mode) {
    return _appRouter.push(RespirarDurationRoute(mode: mode));
  }

  @override
  Future<void> startSession(BreathingMode mode, SessionDuration duration) {
    return _appRouter.push(RespirarSessionRoute(mode: mode, duration: duration));
  }

  @override
  Future<bool?> confirmLeaveSession() {
    return _appRouter.push<bool>(const RespirarLeaveConfirmationRoute());
  }

  @override
  Future<void> resolveLeaveConfirmation({required bool leave}) async {
    _appRouter.pop<bool>(leave);
  }

  @override
  Future<void> leaveSession() async {
    // Force the pop: the session screen vetoes back gestures with its own PopScope.
    _appRouter.pop();
  }

  @override
  Future<void> openSessionEnd() {
    return _appRouter.replace(const RespirarSessionEndRoute());
  }

  @override
  Future<void> openText(String textId) async {
    // TODO(leer): push the Leer context card for [textId] once the Leer module exists.
  }

  @override
  Future<void> openHome() async {
    _appRouter.popUntilRoot();
  }

  @override
  Future<void> close() async {
    _appRouter.popUntil((Route<dynamic> route) => !_respirarRouteNames.contains(route.settings.name));
  }

  @override
  Future<void> back() {
    return _appRouter.maybePop();
  }
}
