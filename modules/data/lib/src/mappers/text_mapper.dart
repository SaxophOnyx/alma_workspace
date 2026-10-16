import 'package:domain/domain.dart';

import '../entities/entities.dart';

final class TextMapper {
  static const String _open = '{';
  static const String _close = '}';
  static const String _separator = '|';

  const TextMapper._();

  static TangoText fromEntity(TextEntity entity) {
    if (entity.id.isEmpty) {
      throw FormatException('Text id is empty', entity.title);
    }
    if (entity.title.trim().isEmpty) {
      throw FormatException('Text title is empty', entity.id);
    }
    if (entity.author.trim().isEmpty) {
      throw FormatException('Text author is empty', entity.id);
    }
    if (entity.context.trim().isEmpty) {
      throw FormatException('Text context is empty', entity.id);
    }
    if (entity.stanzas.isEmpty) {
      throw FormatException('Text has no stanzas', entity.id);
    }

    return TangoText(
      id: entity.id,
      title: entity.title,
      author: entity.author,
      year: entity.year,
      context: entity.context,
      stanzas: entity.stanzas.map((List<String> lines) => _stanzaFromLines(lines, entity.id)).toList(),
    );
  }

  static TextStanza _stanzaFromLines(List<String> lines, String textId) {
    if (lines.isEmpty) {
      throw FormatException('Text has an empty stanza', textId);
    }

    return TextStanza(lines: lines.map(_lineFromMarkup).toList());
  }

  static TextLine _lineFromMarkup(String raw) {
    if (raw.trim().isEmpty) {
      throw FormatException('Text line is empty', raw);
    }

    final List<TextSegment> segments = <TextSegment>[];
    int cursor = 0;
    while (cursor < raw.length) {
      final int open = raw.indexOf(_open, cursor);
      final int strayClose = raw.indexOf(_close, cursor);
      if (strayClose >= 0 && (open < 0 || strayClose < open)) {
        throw FormatException('Unexpected closing brace', raw, strayClose);
      }
      if (open < 0) {
        segments.add(TextSegment(text: raw.substring(cursor)));
        break;
      }
      if (open > cursor) {
        segments.add(TextSegment(text: raw.substring(cursor, open)));
      }

      final int close = raw.indexOf(_close, open + 1);
      if (close < 0) {
        throw FormatException('Unclosed brace', raw, open);
      }
      segments.add(_wordFromMarker(raw.substring(open + 1, close), raw));
      cursor = close + 1;
    }

    return TextLine(segments: segments);
  }

  static TextSegment _wordFromMarker(String marker, String raw) {
    if (marker.contains(_open)) {
      throw FormatException('Nested brace', raw);
    }

    final List<String> parts = marker.split(_separator);
    if (parts.length > 2) {
      throw FormatException('Too many separators in word marker', raw);
    }

    final String surface = parts.first;
    final String wordId = parts.length == 2 ? parts.last : surface.toLowerCase();
    if (surface.trim().isEmpty || wordId.trim().isEmpty) {
      throw FormatException('Empty word marker', raw);
    }

    return TextSegment(text: surface, wordId: wordId);
  }
}
