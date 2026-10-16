import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class TextListItem extends StatelessWidget {
  final String title;
  final String author;
  final int year;
  final VoidCallback onPressed;

  const TextListItem({
    super.key,
    required this.title,
    required this.author,
    required this.year,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final AppTextTheme texts = context.appTexts;
    final AppColorsTheme colors = context.appColors;

    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppDimens.minTouchTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.gapS),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              spacing: AppDimens.gapM,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AppText(
                        text: title,
                        style: texts.menu,
                        maxLines: null,
                        color: colors.textPrimary,
                      ),
                      AppText(
                        text: author,
                        style: texts.captionSmall,
                        color: colors.textSecondary,
                      ),
                    ],
                  ),
                ),
                AppText(
                  text: '$year',
                  style: texts.listTitle,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
