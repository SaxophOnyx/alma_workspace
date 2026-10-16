import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared_ui.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final VoidCallback? onBack;

  /// Small-caps line at the top naming where the screen belongs, like a book's running head.
  final String? runningHead;

  const AppScaffold({
    super.key,
    required this.body,
    this.onBack,
    this.runningHead,
  });

  @override
  Widget build(BuildContext context) {
    final AppColorsTheme colors = context.appColors;
    final VoidCallback? onBack = this.onBack;
    final String? runningHead = this.runningHead;

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
              if (onBack != null || runningHead != null)
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppDimens.screenPadding,
                    top: AppDimens.gapS,
                    right: AppDimens.screenPadding,
                  ),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: AppDimens.minTouchTarget,
                        child: onBack == null ? null : AppBackButton(onPressed: onBack),
                      ),
                      Expanded(
                        child: runningHead == null
                            ? const SizedBox.shrink()
                            : AppText(
                                text: runningHead,
                                style: context.appTexts.smallCaps,
                                textAlign: TextAlign.center,
                                color: colors.textSecondary,
                              ),
                      ),
                      const SizedBox(width: AppDimens.minTouchTarget),
                    ],
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
