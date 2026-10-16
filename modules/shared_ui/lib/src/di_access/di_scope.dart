import 'package:core/core.dart';
import 'package:flutter/material.dart';

class DiScope extends InheritedWidget {
  final GetIt locator;

  const DiScope({
    super.key,
    required this.locator,
    required super.child,
  });

  static GetIt of(BuildContext context) {
    final DiScope? scope = context.getInheritedWidgetOfExactType<DiScope>();
    assert(scope != null, 'DiScope not found in widget tree');
    return scope!.locator;
  }

  @override
  bool updateShouldNotify(DiScope oldWidget) => false;
}
