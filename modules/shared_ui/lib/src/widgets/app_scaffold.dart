import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared_ui.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final VoidCallback? onBack;

  const AppScaffold({
    super.key,
    required this.body,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final AppColorsTheme colors = context.appColors;
    final VoidCallback? onBack = this.onBack;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: colors.background,
      ),
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (onBack != null)
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppDimens.screenPadding,
                    top: AppDimens.screenPadding,
                    right: AppDimens.screenPadding,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AppBackButton(onPressed: onBack),
                  ),
                ),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}
