import 'text_line.dart';

/// A tango line that uses the word; the word itself is one of the line's Lunfardo segments.
class WordExample {
  final TextLine line;
  final String title;
  final int year;
  final String textId;

  const WordExample({
    required this.line,
    required this.title,
    required this.year,
    required this.textId,
  });
}
