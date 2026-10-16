import 'package:flutter/material.dart';

import '../../shared_ui.dart';

/// A row of dots marking the position in a sequence: the current one larger and Oro, the rest Humo.
class AppProgressDots extends StatelessWidget {
  final int count;
  final int index;

  const AppProgressDots({
    super.key,
    required this.count,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final AppColorsTheme colors = context.appColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: AppDimens.gapS,
      children: <Widget>[
        for (int i = 0; i < count; i++)
          AnimatedContainer(
            duration: AppMotions.durationShort,
            curve: AppMotions.standard,
            width: i == index ? AppDimens.progressDotActive : AppDimens.progressDotInactive,
            height: i == index ? AppDimens.progressDotActive : AppDimens.progressDotInactive,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == index ? colors.accent : colors.textSecondary,
            ),
          ),
      ],
    );
  }
}
