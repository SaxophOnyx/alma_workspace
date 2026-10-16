import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../shared_ui.dart';

class AppHighlightedText extends StatefulWidget {
  final String text;
  final String highlight;
  final TextStyle style;
  final VoidCallback? onHighlightTap;

  const AppHighlightedText({
    super.key,
    required this.text,
    required this.highlight,
    required this.style,
    this.onHighlightTap,
  });

  @override
  State<AppHighlightedText> createState() => _AppHighlightedTextState();
}

class _AppHighlightedTextState extends State<AppHighlightedText> {
  late final TapGestureRecognizer _recognizer;

  @override
  void initState() {
    super.initState();
    _recognizer = TapGestureRecognizer()..onTap = _onHighlightTap;
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  void _onHighlightTap() => widget.onHighlightTap?.call();

  @override
  Widget build(BuildContext context) {
    final AppColorsTheme colors = context.appColors;
    final int start = widget.highlight.isEmpty ? -1 : widget.text.indexOf(widget.highlight);

    if (start < 0) {
      return AppText(
        text: widget.text,
        style: widget.style,
        color: colors.textPrimary,
        maxLines: null,
        textAlign: TextAlign.center,
      );
    }

    final int end = start + widget.highlight.length;

    return AppRichText(
      maxLines: null,
      textAlign: TextAlign.center,
      text: TextSpan(
        style: widget.style.copyWith(color: colors.textPrimary),
        children: <InlineSpan>[
          TextSpan(text: widget.text.substring(0, start)),
          TextSpan(
            text: widget.highlight,
            recognizer: widget.onHighlightTap != null ? _recognizer : null,
            style: TextStyle(
              decoration: TextDecoration.underline,
              decorationColor: colors.accent,
              decorationThickness: AppDimens.underlineThickness,
            ),
          ),
          TextSpan(text: widget.text.substring(end)),
        ],
      ),
    );
  }
}
