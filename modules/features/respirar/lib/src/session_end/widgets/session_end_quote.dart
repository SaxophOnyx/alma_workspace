import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class SessionEndQuote extends StatelessWidget {
  final Quote quote;
  final VoidCallback onPressed;

  const SessionEndQuote({
    super.key,
    required this.quote,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final AppTextTheme texts = context.appTexts;
    final AppColorsTheme colors = context.appColors;
    final TextStyle lunfardo = TextStyle(
      decoration: TextDecoration.underline,
      decorationColor: colors.accent,
      decorationThickness: AppDimens.underlineThickness,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: AppRichText(
        maxLines: null,
        textAlign: TextAlign.center,
        text: TextSpan(
          style: texts.poetry.copyWith(color: colors.textPrimary),
          children: <InlineSpan>[
            for (final TextSegment segment in quote.line.segments)
              TextSpan(text: segment.text, style: segment.isLunfardo ? lunfardo : null),
          ],
        ),
      ),
    );
  }
}
