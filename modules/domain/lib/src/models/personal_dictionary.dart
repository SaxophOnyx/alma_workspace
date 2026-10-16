import 'lunfardo_word.dart';

class PersonalDictionary {
  /// Saved words, in the order they were added.
  final List<LunfardoWord> words;
  final int totalWordCount;

  const PersonalDictionary({
    required this.words,
    required this.totalWordCount,
  });

  bool get isComplete => totalWordCount > 0 && words.length >= totalWordCount;
}
