import 'text_stanza.dart';

class TangoText {
  final String id;
  final String title;
  final String author;
  final int year;
  final String context;
  final List<TextStanza> stanzas;

  const TangoText({
    required this.id,
    required this.title,
    required this.author,
    required this.year,
    required this.context,
    required this.stanzas,
  });
}
