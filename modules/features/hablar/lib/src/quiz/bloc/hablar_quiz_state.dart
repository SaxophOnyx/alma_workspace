part of 'hablar_quiz_bloc.dart';

final class HablarQuizState {
  final bool isLoading;
  final List<QuizQuestion> questions;
  final int questionIndex;
  final QuizPhase phase;

  /// Never shown during the quiz; only the result line reports it.
  final int correctCount;
  final bool isNavigating;
  final Exception? error;

  const HablarQuizState({
    this.isLoading = true,
    this.questions = const <QuizQuestion>[],
    this.questionIndex = 0,
    this.phase = QuizPhase.question,
    this.correctCount = 0,
    this.isNavigating = false,
    this.error,
  });

  QuizQuestion? get question => questionIndex < questions.length ? questions[questionIndex] : null;

  static const Object _unset = Object();

  HablarQuizState copyWith({
    bool? isLoading,
    List<QuizQuestion>? questions,
    int? questionIndex,
    QuizPhase? phase,
    int? correctCount,
    bool? isNavigating,
    Object? error = _unset,
  }) {
    return HablarQuizState(
      isLoading: isLoading ?? this.isLoading,
      questions: questions ?? this.questions,
      questionIndex: questionIndex ?? this.questionIndex,
      phase: phase ?? this.phase,
      correctCount: correctCount ?? this.correctCount,
      isNavigating: isNavigating ?? this.isNavigating,
      error: identical(error, _unset) ? this.error : error as Exception?,
    );
  }
}
