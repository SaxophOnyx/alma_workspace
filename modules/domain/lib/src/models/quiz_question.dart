import 'lunfardo_word.dart';
import 'quiz_question_type.dart';

class QuizQuestion {
  final QuizQuestionType type;
  final LunfardoWord word;
  final List<String> options;
  final int correctIndex;

  /// Prompt payload for [QuizQuestionType.related]; empty for the other types.
  final String relatedClue;

  const QuizQuestion({
    required this.type,
    required this.word,
    required this.options,
    required this.correctIndex,
    this.relatedClue = '',
  });

  bool isCorrect(int optionIndex) => optionIndex == correctIndex;
}
