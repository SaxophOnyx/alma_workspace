import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import 'reading_line.dart';

/// The lines of a stanza read so far: the newest in full light, the earlier ones dimmed but kept,
/// so the stanza builds like a verse being spoken.
class ReadingStanza extends StatelessWidget {
  static const double _readOpacity = 0.4;

  final TextStanza stanza;
  final int lineIndex;
  final String? activeWordId;
  final ValueChanged<String> onWordPressed;

  const ReadingStanza({
    super.key,
    required this.stanza,
    required this.lineIndex,
    required this.activeWordId,
    required this.onWordPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppDimens.gapXs,
      children: <Widget>[
        for (int i = 0; i <= lineIndex && i < stanza.lines.length; i++)
          AppFadeIn(
            key: ValueKey<int>(i),
            duration: AppMotions.durationShort,
            child: AnimatedOpacity(
              opacity: i == lineIndex ? 1 : _readOpacity,
              duration: AppMotions.durationMedium,
              curve: AppMotions.standard,
              child: ReadingLine(
                line: stanza.lines[i],
                activeWordId: activeWordId,
                onWordPressed: onWordPressed,
              ),
            ),
          ),
      ],
    );
  }
}
