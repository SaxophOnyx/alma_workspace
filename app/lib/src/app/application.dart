import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:navigation/navigation.dart';
import 'package:shared_ui/shared_ui.dart';

class Application extends StatelessWidget {
  final GetIt locator;

  const Application({
    super.key,
    required this.locator,
  });

  @override
  Widget build(BuildContext context) {
    return DiScope(
      locator: locator,
      child: LocalizationProvider(
        child: Builder(
          builder: (BuildContext context) => MaterialApp.router(
            routerConfig: context.resolve<AppRouter>().config(),
            locale: AppLocales.current,
            supportedLocales: AppLocales.supported,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
          ),
        ),
      ),
    );
  }
}
