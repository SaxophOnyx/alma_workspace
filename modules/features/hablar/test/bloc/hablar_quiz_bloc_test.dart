import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hablar/src/navigation/hablar_navigator.dart';
import 'package:hablar/src/quiz/bloc/hablar_quiz_bloc.dart';
import 'package:hablar/src/quiz/misc/quiz_phase.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/word_fixtures.dart';

class _MockCreateQuizUseCase extends Mock implements CreateQuizUseCase {}

class _MockHablarNavigator extends Mock implements HablarNavigator {}

/// US 8.2: the next question appears after two seconds.
const Duration _explanation = Duration(seconds: 2);
const Duration _justBefore = Duration(milliseconds: 1);

QuizQuestion _question(String id) {
  return QuizQuestion(
    type: QuizQuestionType.meaning,
    word: buildWord(id),
    options: <String>['a', 'b', 'c', 'd'],
    correctIndex: 1,
  );
}

final List<QuizQuestion> _questions = <QuizQuestion>[_question('grela'), _question('mina'), _question('morfar')];

void main() {
  late _MockCreateQuizUseCase createQuiz;
  late _MockHablarNavigator navigator;

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    createQuiz = _MockCreateQuizUseCase();
    navigator = _MockHablarNavigator();
    when(() => createQuiz.execute(any())).thenAnswer((_) async => _questions);
    when(() => navigator.openHablar()).thenAnswer((_) async {});
    when(() => navigator.back()).thenAnswer((_) async {});
  });

  HablarQuizBloc buildBloc() {
    // Default timing on purpose: the spec asks for two seconds.
    return HablarQuizBloc(createQuizUseCase: createQuiz, navigator: navigator);
  }

  HablarQuizState loaded({
    int questionIndex = 0,
    QuizPhase phase = QuizPhase.question,
    int correctCount = 0,
  }) {
    return HablarQuizState(
      isLoading: false,
      questions: _questions,
      questionIndex: questionIndex,
      phase: phase,
      correctCount: correctCount,
    );
  }

  Matcher stateWith({
    required bool isLoading,
    List<QuizQuestion> questions = const <QuizQuestion>[],
    int questionIndex = 0,
    QuizPhase phase = QuizPhase.question,
    int correctCount = 0,
    bool isNavigating = false,
    Matcher error = isNull,
  }) {
    return isA<HablarQuizState>()
        .having((HablarQuizState s) => s.isLoading, 'isLoading', isLoading)
        .having((HablarQuizState s) => s.questions, 'questions', questions)
        .having((HablarQuizState s) => s.questionIndex, 'questionIndex', questionIndex)
        .having((HablarQuizState s) => s.phase, 'phase', phase)
        .having((HablarQuizState s) => s.correctCount, 'correctCount', correctCount)
        .having((HablarQuizState s) => s.isNavigating, 'isNavigating', isNavigating)
        .having((HablarQuizState s) => s.error, 'error', error);
  }

  /// Builds a bloc seeded at [seed] inside fake time, runs [body], then closes the bloc.
  void runQuiz(HablarQuizState seed, void Function(FakeAsync async, HablarQuizBloc bloc) body) {
    fakeAsync((FakeAsync async) {
      final HablarQuizBloc bloc = buildBloc()..emit(seed);
      async.flushMicrotasks();

      body(async, bloc);

      unawaited(bloc.close());
      async.flushMicrotasks();
    });
  }

  void send(FakeAsync async, HablarQuizBloc bloc, HablarQuizEvent event) {
    bloc.add(event);
    async.flushMicrotasks();
  }

  test('initial state is loading on the first question', () {
    final HablarQuizState state = buildBloc().state;

    expect(state.isLoading, isTrue);
    expect(state.questions, isEmpty);
    expect(state.phase, QuizPhase.question);
    expect(state.question, isNull);
  });

  group('QuizStarted', () {
    blocTest<HablarQuizBloc, HablarQuizState>(
      'loads the questions',
      build: buildBloc,
      act: (HablarQuizBloc bloc) => bloc.add(const QuizStarted()),
      expect: () => <Matcher>[
        stateWith(isLoading: true),
        stateWith(isLoading: false, questions: _questions),
      ],
    );

    blocTest<HablarQuizBloc, HablarQuizState>(
      'loads an empty quiz when nothing was encountered',
      setUp: () {
        when(() => createQuiz.execute(any())).thenAnswer((_) async => <QuizQuestion>[]);
      },
      build: buildBloc,
      act: (HablarQuizBloc bloc) => bloc.add(const QuizStarted()),
      expect: () => <Matcher>[
        stateWith(isLoading: true),
        stateWith(isLoading: false),
      ],
    );

    blocTest<HablarQuizBloc, HablarQuizState>(
      'stores the error when the quiz cannot be prepared',
      setUp: () {
        when(() => createQuiz.execute(any())).thenThrow(const EncounteredWordsReadException());
      },
      build: buildBloc,
      act: (HablarQuizBloc bloc) => bloc.add(const QuizStarted()),
      expect: () => <Matcher>[
        stateWith(isLoading: true),
        stateWith(isLoading: false, error: isA<EncounteredWordsReadException>()),
      ],
    );

    test('does not emit when closed while loading', () async {
      final Completer<List<QuizQuestion>> completer = Completer<List<QuizQuestion>>();
      when(() => createQuiz.execute(any())).thenAnswer((_) => completer.future);
      final HablarQuizBloc bloc = buildBloc();
      final List<HablarQuizState> states = <HablarQuizState>[];
      final StreamSubscription<HablarQuizState> subscription = bloc.stream.listen(states.add);

      bloc.add(const QuizStarted());
      await pumpEventQueue();
      await bloc.close();
      completer.complete(_questions);
      await pumpEventQueue();

      expect(states, hasLength(1));
      await subscription.cancel();
    });
  });

  group('OptionSelected', () {
    blocTest<HablarQuizBloc, HablarQuizState>(
      'shows the explanation and counts a right answer',
      build: buildBloc,
      seed: loaded,
      act: (HablarQuizBloc bloc) => bloc.add(const OptionSelected(1)),
      expect: () => <Matcher>[
        stateWith(isLoading: false, questions: _questions, phase: QuizPhase.explanation, correctCount: 1),
      ],
    );

    blocTest<HablarQuizBloc, HablarQuizState>(
      'shows the same explanation without counting a wrong answer',
      build: buildBloc,
      seed: loaded,
      act: (HablarQuizBloc bloc) => bloc.add(const OptionSelected(3)),
      expect: () => <Matcher>[
        stateWith(isLoading: false, questions: _questions, phase: QuizPhase.explanation),
      ],
    );

    blocTest<HablarQuizBloc, HablarQuizState>(
      'counts only the first answer on a double tap',
      build: buildBloc,
      seed: loaded,
      act: (HablarQuizBloc bloc) => bloc
        ..add(const OptionSelected(1))
        ..add(const OptionSelected(1)),
      expect: () => <Matcher>[
        stateWith(isLoading: false, questions: _questions, phase: QuizPhase.explanation, correctCount: 1),
      ],
    );

    blocTest<HablarQuizBloc, HablarQuizState>(
      'is ignored when there are no questions',
      build: buildBloc,
      seed: () => const HablarQuizState(isLoading: false),
      act: (HablarQuizBloc bloc) => bloc.add(const OptionSelected(0)),
      expect: () => <Matcher>[],
    );
  });

  group('explanation timing', () {
    test('moves to the next question after the explanation time', () {
      runQuiz(loaded(), (FakeAsync async, HablarQuizBloc bloc) {
        send(async, bloc, const OptionSelected(1));

        async.elapse(_explanation - _justBefore);
        expect(bloc.state.phase, QuizPhase.explanation);
        expect(bloc.state.questionIndex, 0);

        async.elapse(_justBefore);
        expect(bloc.state.phase, QuizPhase.question);
        expect(bloc.state.questionIndex, 1);
      });
    });

    test('moves on at once on tap and does not skip a question when the time runs out', () {
      runQuiz(loaded(), (FakeAsync async, HablarQuizBloc bloc) {
        send(async, bloc, const OptionSelected(1));
        send(async, bloc, const ExplanationDismissed());
        expect(bloc.state.questionIndex, 1);
        expect(bloc.state.phase, QuizPhase.question);

        async.elapse(_explanation * 2);
        expect(bloc.state.questionIndex, 1);
        expect(bloc.state.phase, QuizPhase.question);
      });
    });

    test('a tap outside the explanation does nothing', () {
      runQuiz(loaded(), (FakeAsync async, HablarQuizBloc bloc) {
        send(async, bloc, const ExplanationDismissed());

        expect(bloc.state.questionIndex, 0);
        expect(bloc.state.phase, QuizPhase.question);
      });
    });

    test('shows the result after the last explanation', () {
      runQuiz(loaded(questionIndex: 2, correctCount: 1), (FakeAsync async, HablarQuizBloc bloc) {
        send(async, bloc, const OptionSelected(1));
        async.elapse(_explanation);

        expect(bloc.state.phase, QuizPhase.result);
        expect(bloc.state.questionIndex, 2);
        expect(bloc.state.correctCount, 2);
      });
    });

    test('a whole quiz reports how many answers were right', () {
      runQuiz(loaded(), (FakeAsync async, HablarQuizBloc bloc) {
        for (final int answer in <int>[1, 0, 1]) {
          send(async, bloc, OptionSelected(answer));
          send(async, bloc, const ExplanationDismissed());
        }

        expect(bloc.state.phase, QuizPhase.result);
        expect(bloc.state.correctCount, 2);
      });
    });

    test('closing during an explanation cancels the timer', () {
      fakeAsync((FakeAsync async) {
        final HablarQuizBloc bloc = buildBloc()..emit(loaded());
        async.flushMicrotasks();
        bloc.add(const OptionSelected(1));
        async.flushMicrotasks();

        unawaited(bloc.close());
        async.flushMicrotasks();
        async.elapse(_explanation);

        expect(async.pendingTimers, isEmpty);
        expect(bloc.state.phase, QuizPhase.explanation);
      });
    });
  });

  group('TryAgainPressed', () {
    blocTest<HablarQuizBloc, HablarQuizState>(
      'prepares a fresh quiz from the result',
      build: buildBloc,
      seed: () => loaded(questionIndex: 2, phase: QuizPhase.result, correctCount: 2),
      act: (HablarQuizBloc bloc) => bloc.add(const TryAgainPressed()),
      expect: () => <Matcher>[
        stateWith(isLoading: true),
        stateWith(isLoading: false, questions: _questions),
      ],
      verify: (_) {
        verify(() => createQuiz.execute(any())).called(1);
      },
    );

    blocTest<HablarQuizBloc, HablarQuizState>(
      'is ignored before the result',
      build: buildBloc,
      seed: loaded,
      act: (HablarQuizBloc bloc) => bloc.add(const TryAgainPressed()),
      expect: () => <Matcher>[],
    );
  });

  group('BackToHablarPressed', () {
    blocTest<HablarQuizBloc, HablarQuizState>(
      'returns to the Hablar main screen',
      build: buildBloc,
      seed: () => loaded(phase: QuizPhase.result),
      act: (HablarQuizBloc bloc) => bloc.add(const BackToHablarPressed()),
      expect: () => <Matcher>[
        stateWith(isLoading: false, questions: _questions, phase: QuizPhase.result, isNavigating: true),
      ],
      verify: (_) {
        verify(() => navigator.openHablar()).called(1);
      },
    );

    blocTest<HablarQuizBloc, HablarQuizState>(
      'navigates only once on a double tap',
      build: buildBloc,
      seed: () => loaded(phase: QuizPhase.result),
      act: (HablarQuizBloc bloc) => bloc
        ..add(const BackToHablarPressed())
        ..add(const BackToHablarPressed()),
      verify: (_) {
        verify(() => navigator.openHablar()).called(1);
      },
    );
  });

  group('QuizBackPressed', () {
    blocTest<HablarQuizBloc, HablarQuizState>(
      'goes back',
      build: buildBloc,
      seed: loaded,
      act: (HablarQuizBloc bloc) => bloc.add(const QuizBackPressed()),
      verify: (_) {
        verify(() => navigator.back()).called(1);
      },
    );

    test('stops the explanation timer when leaving', () {
      runQuiz(loaded(), (FakeAsync async, HablarQuizBloc bloc) {
        send(async, bloc, const OptionSelected(1));
        send(async, bloc, const QuizBackPressed());

        async.elapse(_explanation);
        expect(bloc.state.phase, QuizPhase.explanation);
        expect(bloc.state.questionIndex, 0);
      });
    });
  });
}
