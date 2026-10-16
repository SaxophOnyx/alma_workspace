import 'package:domain/domain.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class ReadingLine extends StatefulWidget {
  final TextLine line;

  /// The word whose annotation is open; drawn in Oro so the reader sees what they asked about.
  final String? activeWordId;
  final ValueChanged<String> onWordPressed;

  const ReadingLine({
    super.key,
    required this.line,
    required this.activeWordId,
    required this.onWordPressed,
  });

  @override
  State<ReadingLine> createState() => _ReadingLineState();
}

class _ReadingLineState extends State<ReadingLine> {
  // One recognizer per Lunfardo segment, aligned with the line's segments (`null` for plain text).
  List<TapGestureRecognizer?> _recognizers = <TapGestureRecognizer?>[];

  @override
  void initState() {
    super.initState();
    _recognizers = _createRecognizers();
  }

  @override
  void didUpdateWidget(ReadingLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.line != widget.line) {
      _disposeRecognizers();
      _recognizers = _createRecognizers();
    }
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  List<TapGestureRecognizer?> _createRecognizers() {
    return <TapGestureRecognizer?>[
      for (final TextSegment segment in widget.line.segments)
        if (segment.wordId case final String wordId)
          TapGestureRecognizer()..onTap = () => widget.onWordPressed(wordId)
        else
          null,
    ];
  }

  void _disposeRecognizers() {
    for (final TapGestureRecognizer? recognizer in _recognizers) {
      recognizer?.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColorsTheme colors = context.appColors;
    final TextStyle underline = TextStyle(
      decoration: TextDecoration.underline,
      decorationColor: colors.accent,
      decorationThickness: AppDimens.underlineThickness,
    );
    final TextStyle active = underline.copyWith(color: colors.accent);
    final List<TextSegment> segments = widget.line.segments;

    return AppRichText(
      maxLines: null,
      text: TextSpan(
        style: context.appTexts.poetry.copyWith(color: colors.textPrimary),
        children: <InlineSpan>[
          for (int i = 0; i < segments.length; i++)
            TextSpan(
              text: segments[i].text,
              style: switch (segments[i]) {
                TextSegment(wordId: final String id) when id == widget.activeWordId => active,
                TextSegment(isLunfardo: true) => underline,
                _ => null,
              },
              recognizer: _recognizers[i],
            ),
        ],
      ),
    );
  }
}
