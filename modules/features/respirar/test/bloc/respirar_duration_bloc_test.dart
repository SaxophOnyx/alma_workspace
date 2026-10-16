import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:respirar/src/duration/bloc/respirar_duration_bloc.dart';
import 'package:respirar/src/navigation/respirar_navigator.dart';

class _MockRespirarNavigator extends Mock implements RespirarNavigator {}

void main() {
  late _MockRespirarNavigator navigator;

  setUpAll(() {
    registerFallbackValue(BreathingMode.compas);
    registerFallbackValue(SessionDuration.twoMinutes);
  });

  setUp(() {
    navigator = _MockRespirarNavigator();
    when(() => navigator.startSession(any(), any())).thenAnswer((_) async {});
    when(() => navigator.back()).thenAnswer((_) async {});
  });

  RespirarDurationBloc buildBloc({BreathingMode mode = BreathingMode.abrazo}) {
    return RespirarDurationBloc(mode: mode, navigator: navigator);
  }

  Matcher stateWith({required bool isNavigating}) {
    return isA<RespirarDurationState>().having(
      (RespirarDurationState s) => s.isNavigating,
      'isNavigating',
      isNavigating,
    );
  }

  group('DurationSelected', () {
    for (final SessionDuration duration in SessionDuration.values) {
      blocTest<RespirarDurationBloc, RespirarDurationState>(
        'starts the session immediately for ${duration.value.inMinutes} min in the selected mode',
        build: buildBloc,
        act: (RespirarDurationBloc bloc) => bloc.add(DurationSelected(duration)),
        expect: () => <Matcher>[
          stateWith(isNavigating: true),
          stateWith(isNavigating: false),
        ],
        verify: (_) {
          verify(() => navigator.startSession(BreathingMode.abrazo, duration)).called(1);
          verifyNoMoreInteractions(navigator);
        },
      );
    }

    test('ignores further taps while the session is open', () async {
      final Completer<void> completer = Completer<void>();
      when(() => navigator.startSession(any(), any())).thenAnswer((_) => completer.future);
      final RespirarDurationBloc bloc = buildBloc();

      bloc
        ..add(const DurationSelected(SessionDuration.twoMinutes))
        ..add(const DurationSelected(SessionDuration.fiveMinutes));
      await pumpEventQueue();
      completer.complete();
      await pumpEventQueue();

      verify(() => navigator.startSession(BreathingMode.abrazo, SessionDuration.twoMinutes)).called(1);
      verifyNever(() => navigator.startSession(any(), SessionDuration.fiveMinutes));

      await bloc.close();
    });

    blocTest<RespirarDurationBloc, RespirarDurationState>(
      'becomes usable again when navigation fails',
      setUp: () {
        when(() => navigator.startSession(any(), any())).thenAnswer((_) async => throw Exception('boom'));
      },
      build: buildBloc,
      act: (RespirarDurationBloc bloc) => bloc.add(const DurationSelected(SessionDuration.tenMinutes)),
      expect: () => <Matcher>[
        stateWith(isNavigating: true),
        stateWith(isNavigating: false),
      ],
    );
  });

  group('DurationBackPressed', () {
    blocTest<RespirarDurationBloc, RespirarDurationState>(
      'navigates back to mode selection',
      build: buildBloc,
      act: (RespirarDurationBloc bloc) => bloc.add(const DurationBackPressed()),
      expect: () => <Matcher>[],
      verify: (_) {
        verify(() => navigator.back()).called(1);
        verifyNoMoreInteractions(navigator);
      },
    );

    test('is ignored while a session is starting', () async {
      final Completer<void> completer = Completer<void>();
      when(() => navigator.startSession(any(), any())).thenAnswer((_) => completer.future);
      final RespirarDurationBloc bloc = buildBloc();

      bloc
        ..add(const DurationSelected(SessionDuration.twoMinutes))
        ..add(const DurationBackPressed());
      await pumpEventQueue();

      verifyNever(() => navigator.back());
      completer.complete();
      await bloc.close();
    });
  });
}
