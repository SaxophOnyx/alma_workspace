import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class DictionaryWordItem extends StatelessWidget {
  final String word;
  final String meaning;
  final VoidCallback onPressed;

  const DictionaryWordItem({
    super.key,
    required this.word,
    required this.meaning,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppText(
                  text: word,
                  style: context.appTexts.menu,
                  maxLines: null,
                  color: colors.textPrimary,
                ),
                AppText(
                  text: meaning,
                  style: context.appTexts.captionSmall,
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
