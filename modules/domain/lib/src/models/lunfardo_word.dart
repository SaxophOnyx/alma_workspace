import 'word_example.dart';

class LunfardoWord {
  final String id;
  final String word;
  final String pronunciation;
  final String meaning;

  /// Steps of the etymology chain, from the oldest source to the Lunfardo sense.
  final List<String> etymology;
  final WordExample example;

  /// Display-only related words; they are not necessarily Lunfardo word ids.
  final List<String> related;

  const LunfardoWord({
    required this.id,
    required this.word,
    required this.pronunciation,
    required this.meaning,
    required this.etymology,
    required this.example,
    required this.related,
  });
}
