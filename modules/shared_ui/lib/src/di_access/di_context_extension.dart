import 'package:flutter/material.dart';

import 'di_scope.dart';

extension DiContextExtension on BuildContext {
  T resolve<T extends Object>() => DiScope.of(this).get<T>();
}
