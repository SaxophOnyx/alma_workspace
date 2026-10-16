part of 'hablar_quiz_bloc.dart';

sealed class HablarQuizEvent {
  const HablarQuizEvent();
}

final class QuizStarted extends HablarQuizEvent {
  const QuizStarted();
}

final class OptionSelected extends HablarQuizEvent {
  final int optionIndex;

  const OptionSelected(this.optionIndex);
}

/// Tap on the explanation; moves on before the explanation time runs out.
final class ExplanationDismissed extends HablarQuizEvent {
  const ExplanationDismissed();
}

final class TryAgainPressed extends HablarQuizEvent {
  const TryAgainPressed();
}

final class BackToHablarPressed extends HablarQuizEvent {
  const BackToHablarPressed();
}

final class QuizBackPressed extends HablarQuizEvent {
  const QuizBackPressed();
}

final class _ExplanationTimeElapsed extends HablarQuizEvent {
  const _ExplanationTimeElapsed();
}
