import 'package:core/core.dart';

final class DomainDI {
  const DomainDI._();

  static void initDependencies(GetIt locator) {
    _initUseCases(locator);
  }

  static void _initUseCases(GetIt locator) {}
}
