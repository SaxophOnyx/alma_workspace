import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launch/src/bloc/launch_bloc.dart';
import 'package:launch/src/navigation/launch_navigator.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetOnboardingCompletedUseCase extends Mock implements GetOnboardingCompletedUseCase {}

class _MockLaunchNavigator extends Mock implements LaunchNavigator {}

void main() {
  late _MockGetOnboardingCompletedUseCase getOnboardingCompletedUseCase;
  late _MockLaunchNavigator navigator;

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    getOnboardingCompletedUseCase = _MockGetOnboardingCompletedUseCase();
    navigator = _MockLaunchNavigator();
    when(() => navigator.openHome()).thenAnswer((_) async {});
    when(() => navigator.openOnboarding()).thenAnswer((_) async {});
  });

  LaunchBloc buildBloc() {
    return LaunchBloc(
      getOnboardingCompletedUseCase: getOnboardingCompletedUseCase,
      navigator: navigator,
      brandDuration: Duration.zero,
    );
  }

  test('initial state is not checking', () {
    expect(buildBloc().state.isChecking, isFalse);
  });

  group('LaunchStarted', () {
    blocTest<LaunchBloc, LaunchState>(
      'opens Home when onboarding is completed',
      setUp: () {
        when(() => getOnboardingCompletedUseCase.execute(any())).thenAnswer((_) async => true);
      },
      build: buildBloc,
      act: (LaunchBloc bloc) => bloc.add(const LaunchStarted()),
      expect: () => <Matcher>[
        isA<LaunchState>().having((LaunchState s) => s.isChecking, 'isChecking', isTrue),
      ],
      verify: (_) {
        verify(() => getOnboardingCompletedUseCase.execute(any(that: isA<NoParams>()))).called(1);
        verify(() => navigator.openHome()).called(1);
        verifyNever(() => navigator.openOnboarding());
      },
    );

    blocTest<LaunchBloc, LaunchState>(
      'opens Onboarding when onboarding is not completed',
      setUp: () {
        when(() => getOnboardingCompletedUseCase.execute(any())).thenAnswer((_) async => false);
      },
      build: buildBloc,
      act: (LaunchBloc bloc) => bloc.add(const LaunchStarted()),
      // The first-launch brand pause is zero here but still yields to the event loop.
      wait: Duration.zero,
      expect: () => <Matcher>[
        isA<LaunchState>().having((LaunchState s) => s.isChecking, 'isChecking', isTrue),
      ],
      verify: (_) {
        verify(() => navigator.openOnboarding()).called(1);
        verifyNever(() => navigator.openHome());
      },
    );

    blocTest<LaunchBloc, LaunchState>(
      'falls back to Onboarding when reading the flag fails',
      setUp: () {
        when(() => getOnboardingCompletedUseCase.execute(any())).thenThrow(const OnboardingStatusReadException());
      },
      build: buildBloc,
      act: (LaunchBloc bloc) => bloc.add(const LaunchStarted()),
      // The first-launch brand pause is zero here but still yields to the event loop.
      wait: Duration.zero,
      expect: () => <Matcher>[
        isA<LaunchState>().having((LaunchState s) => s.isChecking, 'isChecking', isTrue),
      ],
      verify: (_) {
        verify(() => navigator.openOnboarding()).called(1);
        verifyNever(() => navigator.openHome());
      },
    );

    blocTest<LaunchBloc, LaunchState>(
      'falls back to Onboarding on an unexpected exception',
      setUp: () {
        when(() => getOnboardingCompletedUseCase.execute(any())).thenAnswer((_) async => throw Exception('boom'));
      },
      build: buildBloc,
      act: (LaunchBloc bloc) => bloc.add(const LaunchStarted()),
      // The first-launch brand pause is zero here but still yields to the event loop.
      wait: Duration.zero,
      verify: (_) {
        verify(() => navigator.openOnboarding()).called(1);
        verifyNever(() => navigator.openHome());
      },
    );

    blocTest<LaunchBloc, LaunchState>(
      'checks only once when started twice rapidly',
      setUp: () {
        when(() => getOnboardingCompletedUseCase.execute(any())).thenAnswer((_) async => true);
      },
      build: buildBloc,
      act: (LaunchBloc bloc) => bloc
        ..add(const LaunchStarted())
        ..add(const LaunchStarted()),
      expect: () => <Matcher>[
        isA<LaunchState>().having((LaunchState s) => s.isChecking, 'isChecking', isTrue),
      ],
      verify: (_) {
        verify(() => getOnboardingCompletedUseCase.execute(any())).called(1);
        verify(() => navigator.openHome()).called(1);
      },
    );

    test('does not navigate or emit when closed while the check is in flight', () async {
      final Completer<bool> completer = Completer<bool>();
      when(() => getOnboardingCompletedUseCase.execute(any())).thenAnswer((_) => completer.future);
      final LaunchBloc bloc = buildBloc();
      final List<LaunchState> states = <LaunchState>[];
      final StreamSubscription<LaunchState> subscription = bloc.stream.listen(states.add);

      bloc.add(const LaunchStarted());
      await pumpEventQueue();
      await bloc.close();
      completer.complete(true);
      await pumpEventQueue();
      await subscription.cancel();

      expect(states, hasLength(1));
      verifyNever(() => navigator.openHome());
      verifyNever(() => navigator.openOnboarding());
    });
  });
}
