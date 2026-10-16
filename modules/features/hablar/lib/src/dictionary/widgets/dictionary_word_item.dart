import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class DictionaryWordItem extends StatelessWidget {
  final String word;
  final VoidCallback onPressed;

  const DictionaryWordItem({
    super.key,
    required this.word,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppDimens.minTouchTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.gapS),
            child: AppText(
              text: word,
              style: context.appTexts.listTitle,
              maxLines: null,
              color: context.appColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
