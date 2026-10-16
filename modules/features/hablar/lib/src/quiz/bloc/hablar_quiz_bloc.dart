import 'dart:async';

import 'package:domain/domain.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../navigation/hablar_navigator.dart';
import '../misc/quiz_phase.dart';

part 'hablar_quiz_event.dart';
part 'hablar_quiz_state.dart';

class HablarQuizBloc extends Bloc<HablarQuizEvent, HablarQuizState> {
  final CreateQuizUseCase _createQuizUseCase;
  final HablarNavigator _navigator;
  final Duration _explanationDuration;

  Timer? _explanationTimer;

  HablarQuizBloc({
    required CreateQuizUseCase createQuizUseCase,
    required HablarNavigator navigator,
    Duration explanationDuration = AppMotions.silenceShort,
  }) : _createQuizUseCase = createQuizUseCase,
       _navigator = navigator,
       _explanationDuration = explanationDuration,
       super(const HablarQuizState()) {
    on<QuizStarted>(_onStarted);
    on<OptionSelected>(_onOptionSelected);
    on<ExplanationDismissed>(_onExplanationDismissed);
    on<_ExplanationTimeElapsed>(_onExplanationTimeElapsed);
    on<TryAgainPressed>(_onTryAgainPressed);
    on<BackToHablarPressed>(_onBackToHablarPressed);
    on<QuizBackPressed>(_onBackPressed);
  }

  Future<void> _onStarted(QuizStarted event, Emitter<HablarQuizState> emit) {
    return _loadQuiz(emit);
  }

  void _onOptionSelected(OptionSelected event, Emitter<HablarQuizState> emit) {
    final QuizQuestion? question = state.question;
    if (question == null || state.phase != QuizPhase.question) return;

    emit(
      state.copyWith(
        phase: QuizPhase.explanation,
        correctCount: state.correctCount + (question.isCorrect(event.optionIndex) ? 1 : 0),
      ),
    );
    _explanationTimer?.cancel();
    _explanationTimer = Timer(_explanationDuration, () {
      if (!isClosed) add(const _ExplanationTimeElapsed());
    });
  }

  void _onExplanationDismissed(ExplanationDismissed event, Emitter<HablarQuizState> emit) {
    _advance(emit);
  }

  void _onExplanationTimeElapsed(_ExplanationTimeElapsed event, Emitter<HablarQuizState> emit) {
    _advance(emit);
  }

  Future<void> _onTryAgainPressed(TryAgainPressed event, Emitter<HablarQuizState> emit) async {
    if (state.phase != QuizPhase.result || state.isLoading) return;
    await _loadQuiz(emit);
  }

  Future<void> _onBackToHablarPressed(BackToHablarPressed event, Emitter<HablarQuizState> emit) async {
    if (state.isNavigating) return;
    emit(state.copyWith(isNavigating: true));

    _explanationTimer?.cancel();
    await _navigator.openHablar();
  }

  Future<void> _onBackPressed(QuizBackPressed event, Emitter<HablarQuizState> emit) async {
    if (state.isNavigating) return;
    emit(state.copyWith(isNavigating: true));

    _explanationTimer?.cancel();
    await _navigator.back();
  }

  void _advance(Emitter<HablarQuizState> emit) {
    if (state.phase != QuizPhase.explanation) return;
    _explanationTimer?.cancel();

    final int next = state.questionIndex + 1;
    if (next < state.questions.length) {
      emit(state.copyWith(questionIndex: next, phase: QuizPhase.question));
    } else {
      emit(state.copyWith(phase: QuizPhase.result));
    }
  }

  Future<void> _loadQuiz(Emitter<HablarQuizState> emit) async {
    _explanationTimer?.cancel();
    emit(
      state.copyWith(
        isLoading: true,
        questions: const <QuizQuestion>[],
        questionIndex: 0,
        phase: QuizPhase.question,
        correctCount: 0,
        error: null,
      ),
    );

    try {
      final List<QuizQuestion> questions = await _createQuizUseCase.execute(const NoParams());
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, questions: questions));
    } on Exception catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, error: e));
    }
  }

  @override
  Future<void> close() {
    _explanationTimer?.cancel();
    return super.close();
  }
}
