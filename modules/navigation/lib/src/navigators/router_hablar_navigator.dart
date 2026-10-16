import 'package:hablar/hablar.dart';
import 'package:leer/leer.dart';

import '../router/app_router.dart';

final class RouterHablarNavigator implements HablarNavigator {
  final AppRouter _appRouter;

  const RouterHablarNavigator({
    required AppRouter appRouter,
  }) : _appRouter = appRouter;

  @override
  Future<void> openWordOfTheDay() {
    return _appRouter.push<void>(HablarWordCardRoute());
  }

  @override
  Future<void> openWordCard(String wordId) {
    return _appRouter.push<void>(HablarWordCardRoute(wordId: wordId));
  }

  @override
  Future<void> openDictionary() {
    return _appRouter.push<void>(const HablarDictionaryRoute());
  }

  @override
  Future<void> openQuiz() {
    return _appRouter.push<void>(const HablarQuizRoute());
  }

  @override
  Future<void> openText(String textId) {
    return _appRouter.push(LeerContextRoute(textId: textId));
  }

  @override
  Future<void> openHablar() async {
    _appRouter.popUntilRouteWithName(HablarMainRoute.name);
  }

  @override
  Future<void> back() {
    return _appRouter.maybePop();
  }
}
