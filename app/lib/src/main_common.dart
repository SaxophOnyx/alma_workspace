import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/widgets.dart';
import 'package:navigation/navigation.dart';

import 'app/application.dart';

void mainCommon(BuildFlavor flavor) {
  final GetIt locator = GetIt.asNewInstance();

  CoreDI.initDependencies(locator);
  DataDI.initDependencies(locator);
  DomainDI.initDependencies(locator);
  NavigationDI.initDependencies(locator);

  runApp(Application(locator: locator));
}
