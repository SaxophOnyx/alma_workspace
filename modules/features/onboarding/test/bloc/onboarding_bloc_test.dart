import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:onboarding/src/bloc/onboarding_bloc.dart';
import 'package:onboarding/src/navigation/onboarding_navigator.dart';

class _MockCompleteOnboardingUseCase extends Mock implements CompleteOnboardingUseCase {}

class _MockOnboardingNavigator extends Mock implements OnboardingNavigator {}

void main() {
  late _MockCompleteOnboardingUseCase completeOnboardingUseCase;
  late _MockOnboardingNavigator navigator;

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    completeOnboardingUseCase = _MockCompleteOnboardingUseCase();
    navigator = _MockOnboardingNavigator();
    when(() => completeOnboardingUseCase.execute(any())).thenAnswer((_) async {});
    when(() => navigator.openHome()).thenAnswer((_) async {});
  });

  OnboardingBloc buildBloc({Duration enterHighlightDuration = Duration.zero}) {
    return OnboardingBloc(
      completeOnboardingUseCase: completeOnboardingUseCase,
      navigator: navigator,
      enterHighlightDuration: enterHighlightDuration,
    );
  }

  Matcher stateWith({required bool isCompleting, required bool isEnterHighlighted}) {
    return isA<OnboardingState>()
        .having((OnboardingState s) => s.isCompleting, 'isCompleting', isCompleting)
        .having((OnboardingState s) => s.isEnterHighlighted, 'isEnterHighlighted', isEnterHighlighted);
  }

  test('initial state is idle and not highlighted', () {
    final OnboardingState state = buildBloc().state;

    expect(state.isCompleting, isFalse);
    expect(state.isEnterHighlighted, isFalse);
  });

  group('SkipPressed', () {
    blocTest<OnboardingBloc, OnboardingState>(
      'completes onboarding, then opens Home',
      build: buildBloc,
      act: (OnboardingBloc bloc) => bloc.add(const SkipPressed()),
      expect: () => <Matcher>[
        stateWith(isCompleting: true, isEnterHighlighted: false),
      ],
      verify: (_) {
        verifyInOrder(<void Function()>[
          () => completeOnboardingUseCase.execute(any(that: isA<NoParams>())),
          () => navigator.openHome(),
        ]);
        verifyNoMoreInteractions(completeOnboardingUseCase);
        verifyNoMoreInteractions(navigator);
      },
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'still opens Home when saving the flag fails',
      setUp: () {
        when(() => completeOnboardingUseCase.execute(any())).thenThrow(const OnboardingStatusWriteException());
      },
      build: buildBloc,
      act: (OnboardingBloc bloc) => bloc.add(const SkipPressed()),
      expect: () => <Matcher>[
        stateWith(isCompleting: true, isEnterHighlighted: false),
      ],
      verify: (_) {
        verify(() => navigator.openHome()).called(1);
      },
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'still opens Home on an unexpected exception',
      setUp: () {
        when(() => completeOnboardingUseCase.execute(any())).thenAnswer((_) async => throw Exception('boom'));
      },
      build: buildBloc,
      act: (OnboardingBloc bloc) => bloc.add(const SkipPressed()),
      verify: (_) {
        verify(() => navigator.openHome()).called(1);
      },
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'completes only once when tapped twice rapidly',
      build: buildBloc,
      act: (OnboardingBloc bloc) => bloc
        ..add(const SkipPressed())
        ..add(const SkipPressed()),
      expect: () => <Matcher>[
        stateWith(isCompleting: true, isEnterHighlighted: false),
      ],
      verify: (_) {
        verify(() => completeOnboardingUseCase.execute(any())).called(1);
        verify(() => navigator.openHome()).called(1);
      },
    );

    test('does not open Home when closed while saving is in flight', () async {
      final Completer<void> completer = Completer<void>();
      when(() => completeOnboardingUseCase.execute(any())).thenAnswer((_) => completer.future);
      final OnboardingBloc bloc = buildBloc();

      bloc.add(const SkipPressed());
      await pumpEventQueue();
      await bloc.close();
      completer.complete();
      await pumpEventQueue();

      verifyNever(() => navigator.openHome());
    });
  });

  group('EnterPressed', () {
    blocTest<OnboardingBloc, OnboardingState>(
      'highlights Enter, completes onboarding, then opens Home',
      build: buildBloc,
      act: (OnboardingBloc bloc) => bloc.add(const EnterPressed()),
      expect: () => <Matcher>[
        stateWith(isCompleting: true, isEnterHighlighted: true),
      ],
      verify: (_) {
        verifyInOrder(<void Function()>[
          () => completeOnboardingUseCase.execute(any(that: isA<NoParams>())),
          () => navigator.openHome(),
        ]);
        verifyNoMoreInteractions(navigator);
      },
    );

    test('waits for the highlight duration before opening Home', () async {
      final OnboardingBloc bloc = buildBloc(enterHighlightDuration: const Duration(milliseconds: 100));

      bloc.add(const EnterPressed());
      await Future<void>.delayed(const Duration(milliseconds: 30));
      verifyNever(() => navigator.openHome());

      await Future<void>.delayed(const Duration(milliseconds: 120));
      verify(() => navigator.openHome()).called(1);

      await bloc.close();
    });

    test('waits for saving to finish when it outlasts the highlight', () async {
      final Completer<void> completer = Completer<void>();
      when(() => completeOnboardingUseCase.execute(any())).thenAnswer((_) => completer.future);
      final OnboardingBloc bloc = buildBloc();

      bloc.add(const EnterPressed());
      await pumpEventQueue();
      verifyNever(() => navigator.openHome());

      completer.complete();
      await pumpEventQueue();
      verify(() => navigator.openHome()).called(1);

      await bloc.close();
    });

    blocTest<OnboardingBloc, OnboardingState>(
      'still opens Home when saving the flag fails',
      setUp: () {
        when(() => completeOnboardingUseCase.execute(any())).thenThrow(const OnboardingStatusWriteException());
      },
      build: buildBloc,
      act: (OnboardingBloc bloc) => bloc.add(const EnterPressed()),
      expect: () => <Matcher>[
        stateWith(isCompleting: true, isEnterHighlighted: true),
      ],
      verify: (_) {
        verify(() => navigator.openHome()).called(1);
      },
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'is ignored after Skip already started completing',
      build: buildBloc,
      act: (OnboardingBloc bloc) => bloc
        ..add(const SkipPressed())
        ..add(const EnterPressed()),
      expect: () => <Matcher>[
        stateWith(isCompleting: true, isEnterHighlighted: false),
      ],
      verify: (_) {
        verify(() => completeOnboardingUseCase.execute(any())).called(1);
        verify(() => navigator.openHome()).called(1);
      },
    );

    blocTest<OnboardingBloc, OnboardingState>(
      'completes only once when tapped twice rapidly',
      build: buildBloc,
      act: (OnboardingBloc bloc) => bloc
        ..add(const EnterPressed())
        ..add(const EnterPressed()),
      expect: () => <Matcher>[
        stateWith(isCompleting: true, isEnterHighlighted: true),
      ],
      verify: (_) {
        verify(() => completeOnboardingUseCase.execute(any())).called(1);
        verify(() => navigator.openHome()).called(1);
      },
    );

    test('does not open Home when closed during the highlight', () async {
      final OnboardingBloc bloc = buildBloc(enterHighlightDuration: const Duration(milliseconds: 50));

      bloc.add(const EnterPressed());
      await pumpEventQueue();
      await bloc.close();
      await Future<void>.delayed(const Duration(milliseconds: 80));

      verifyNever(() => navigator.openHome());
    });
  });
}
