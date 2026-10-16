import 'text_line.dart';

class Quote {
  /// The quoted lines, with Lunfardo words marked as in a text.
  final TextLine line;
  final String title;
  final int year;
  final String textId;

  const Quote({
    required this.line,
    required this.title,
    required this.year,
    required this.textId,
  });
}
