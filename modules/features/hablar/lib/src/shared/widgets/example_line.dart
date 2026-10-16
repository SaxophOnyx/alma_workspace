import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

/// A tango line with [wordId] underlined in Oro, or replaced by [blank] when one is given.
class ExampleLine extends StatelessWidget {
  final TextLine line;
  final String wordId;
  final String? blank;

  const ExampleLine({
    super.key,
    required this.line,
    required this.wordId,
    this.blank,
  });

  @override
  Widget build(BuildContext context) {
    final AppColorsTheme colors = context.appColors;
    final TextStyle marked = TextStyle(
      decoration: TextDecoration.underline,
      decorationColor: colors.accent,
      decorationThickness: AppDimens.underlineThickness,
    );

    return AppRichText(
      maxLines: null,
      text: TextSpan(
        style: context.appTexts.quote.copyWith(color: colors.textPrimary),
        children: <InlineSpan>[
          for (final TextSegment segment in line.segments)
            if (segment.wordId == wordId)
              TextSpan(text: blank ?? segment.text, style: marked)
            else
              TextSpan(text: segment.text),
        ],
      ),
    );
  }
}
