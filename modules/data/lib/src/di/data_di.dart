import 'package:core/core.dart';

final class DataDI {
  const DataDI._();

  static void initDependencies(GetIt locator) {
    _initProviders(locator);
    _initRepositories(locator);
  }

  static void _initProviders(GetIt locator) {}

  static void _initRepositories(GetIt locator) {}
}
