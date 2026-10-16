import 'dart:async';

import 'package:domain/domain.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:respirar/src/navigation/respirar_navigator.dart';
import 'package:respirar/src/session/bloc/respirar_session_bloc.dart';

class _MockGetBreathingPatternUseCase extends Mock implements GetBreathingPatternUseCase {}

class _MockPlayPhaseHapticUseCase extends Mock implements PlayPhaseHapticUseCase {}

class _MockSetScreenAwakeUseCase extends Mock implements SetScreenAwakeUseCase {}

class _MockRespirarNavigator extends Mock implements RespirarNavigator {}

const BreathingPattern _compas = BreathingPattern(
  mode: BreathingMode.compas,
  phases: <BreathingPhase>[
    BreathingPhase(type: BreathingPhaseType.inhale, duration: Duration(milliseconds: 6000)),
    BreathingPhase(type: BreathingPhaseType.hold, duration: Duration(milliseconds: 1500)),
    BreathingPhase(type: BreathingPhaseType.exhale, duration: Duration(milliseconds: 4500)),
  ],
);

const BreathingPattern _pausa = BreathingPattern(
  mode: BreathingMode.pausa,
  phases: <BreathingPhase>[
    BreathingPhase(type: BreathingPhaseType.inhale, duration: Duration(seconds: 4)),
    BreathingPhase(type: BreathingPhaseType.exhale, duration: Duration(seconds: 4)),
    BreathingPhase(type: BreathingPhaseType.hold, duration: Duration(seconds: 3)),
  ],
  holdProgression: HoldProgression(
    phaseIndex: 2,
    from: Duration(seconds: 3),
    to: Duration(seconds: 12),
    step: Duration(seconds: 1),
  ),
);

const Duration _fadeOut = Duration(milliseconds: 1500);

void main() {
  late _MockGetBreathingPatternUseCase getPattern;
  late _MockPlayPhaseHapticUseCase playHaptic;
  late _MockSetScreenAwakeUseCase setScreenAwake;
  late _MockRespirarNavigator navigator;

  setUpAll(() {
    registerFallbackValue(const GetBreathingPatternParams(mode: BreathingMode.compas));
    registerFallbackValue(const NoParams());
    registerFallbackValue(const SetScreenAwakeParams(enabled: false));
  });

  setUp(() {
    getPattern = _MockGetBreathingPatternUseCase();
    playHaptic = _MockPlayPhaseHapticUseCase();
    setScreenAwake = _MockSetScreenAwakeUseCase();
    navigator = _MockRespirarNavigator();

    when(() => getPattern.execute(any())).thenAnswer((Invocation invocation) async {
      final GetBreathingPatternParams params = invocation.positionalArguments.single as GetBreathingPatternParams;
      return params.mode == BreathingMode.pausa ? _pausa : _compas;
    });
    when(() => playHaptic.execute(any())).thenAnswer((_) async {});
    when(() => setScreenAwake.execute(any())).thenAnswer((_) async {});
    when(() => navigator.confirmLeaveSession()).thenAnswer((_) async => false);
    when(() => navigator.leaveSession()).thenAnswer((_) async {});
    when(() => navigator.openSessionEnd()).thenAnswer((_) async {});
  });

  RespirarSessionBloc buildBloc({
    BreathingMode mode = BreathingMode.compas,
    SessionDuration duration = SessionDuration.twoMinutes,
  }) {
    return RespirarSessionBloc(
      mode: mode,
      duration: duration,
      getBreathingPatternUseCase: getPattern,
      playPhaseHapticUseCase: playHaptic,
      setScreenAwakeUseCase: setScreenAwake,
      navigator: navigator,
      fadeOutDuration: _fadeOut,
    );
  }

  /// Builds a started bloc inside fake time, runs [body], then closes the bloc.
  void runSession(
    void Function(FakeAsync async, RespirarSessionBloc bloc) body, {
    BreathingMode mode = BreathingMode.compas,
    SessionDuration duration = SessionDuration.twoMinutes,
  }) {
    fakeAsync((FakeAsync async) {
      final RespirarSessionBloc bloc = buildBloc(mode: mode, duration: duration);
      bloc.add(const SessionStarted());
      async.flushMicrotasks();

      body(async, bloc);

      unawaited(bloc.close());
      async.flushMicrotasks();
    });
  }

  Matcher awakeParams({required bool enabled}) {
    return isA<SetScreenAwakeParams>().having((SetScreenAwakeParams p) => p.enabled, 'enabled', enabled);
  }

  test('initial state has no phase and is not running', () {
    final RespirarSessionBloc bloc = buildBloc();

    expect(bloc.state.phaseType, isNull);
    expect(bloc.state.phaseNumber, 0);
    expect(bloc.state.isPaused, isFalse);
    expect(bloc.state.isFinished, isFalse);
    expect(bloc.state.error, isNull);
  });

  group('SessionStarted', () {
    test('loads the pattern for the mode and starts the first inhale without a haptic', () {
      runSession(mode: BreathingMode.pausa, (FakeAsync async, RespirarSessionBloc bloc) {
        expect(bloc.state.isLoading, isFalse);
        expect(bloc.state.phaseType, BreathingPhaseType.inhale);
        expect(bloc.state.phaseDuration, const Duration(seconds: 4));
        expect(bloc.state.phaseNumber, 1);

        verify(
          () => getPattern.execute(
            any(
              that: isA<GetBreathingPatternParams>().having(
                (GetBreathingPatternParams p) => p.mode,
                'mode',
                BreathingMode.pausa,
              ),
            ),
          ),
        ).called(1);
        verifyNever(() => playHaptic.execute(any()));
      });
    });

    test('keeps the screen awake once started', () {
      runSession((FakeAsync async, RespirarSessionBloc bloc) {
        verify(() => setScreenAwake.execute(any(that: awakeParams(enabled: true)))).called(1);
      });
    });

    test('loads the pattern only once when started twice', () {
      runSession((FakeAsync async, RespirarSessionBloc bloc) {
        bloc.add(const SessionStarted());
        async.flushMicrotasks();

        verify(() => getPattern.execute(any())).called(1);
        expect(bloc.state.phaseNumber, 1);
      });
    });

    test('stores the error and leaves the session when the pattern cannot load', () {
      when(() => getPattern.execute(any())).thenThrow(const BreathingPatternLoadException());

      runSession((FakeAsync async, RespirarSessionBloc bloc) {
        expect(bloc.state.error, isA<BreathingPatternLoadException>());
        expect(bloc.state.isLoading, isFalse);
        expect(bloc.state.phaseType, isNull);
        verify(() => navigator.leaveSession()).called(1);
        verifyNever(() => setScreenAwake.execute(any(that: awakeParams(enabled: true))));
      });
    });

    test('clears a previous error when retried successfully', () {
      fakeAsync((FakeAsync async) {
        when(() => getPattern.execute(any())).thenThrow(const BreathingPatternLoadException());
        final RespirarSessionBloc bloc = buildBloc();
        bloc.add(const SessionStarted());
        async.flushMicrotasks();
        expect(bloc.state.error, isNotNull);

        when(() => getPattern.execute(any())).thenAnswer((_) async => _compas);
        bloc.add(const SessionStarted());
        async.flushMicrotasks();

        expect(bloc.state.error, isNull);
        expect(bloc.state.phaseType, BreathingPhaseType.inhale);

        unawaited(bloc.close());
        async.flushMicrotasks();
      });
    });

    test('does not emit or start when closed while loading', () {
      fakeAsync((FakeAsync async) {
        final Completer<BreathingPattern> completer = Completer<BreathingPattern>();
        when(() => getPattern.execute(any())).thenAnswer((_) => completer.future);
        final RespirarSessionBloc bloc = buildBloc();
        final List<RespirarSessionState> states = <RespirarSessionState>[];
        final StreamSubscription<RespirarSessionState> subscription = bloc.stream.listen(states.add);

        bloc.add(const SessionStarted());
        async.flushMicrotasks();
        unawaited(bloc.close());
        completer.complete(_compas);
        async.elapse(const Duration(minutes: 5));

        expect(states.where((RespirarSessionState s) => s.phaseType != null), isEmpty);
        verifyNever(() => playHaptic.execute(any()));
        unawaited(subscription.cancel());
      });
    });
  });

  group('phase rhythm', () {
    test('advances through Compás with exact phase durations and wraps to the next cycle', () {
      runSession((FakeAsync async, RespirarSessionBloc bloc) {
        async.elapse(const Duration(milliseconds: 5999));
        expect(bloc.state.phaseNumber, 1);

        async.elapse(const Duration(milliseconds: 1));
        expect(bloc.state.phaseType, BreathingPhaseType.hold);
        expect(bloc.state.phaseDuration, const Duration(milliseconds: 1500));
        expect(bloc.state.phaseNumber, 2);

        async.elapse(const Duration(milliseconds: 1500));
        expect(bloc.state.phaseType, BreathingPhaseType.exhale);
        expect(bloc.state.phaseDuration, const Duration(milliseconds: 4500));
        expect(bloc.state.phaseNumber, 3);

        async.elapse(const Duration(milliseconds: 4500));
        expect(bloc.state.phaseType, BreathingPhaseType.inhale);
        expect(bloc.state.phaseDuration, const Duration(milliseconds: 6000));
        expect(bloc.state.phaseNumber, 4);
      });
    });

    test('emits exactly one haptic pulse per phase transition', () {
      runSession((FakeAsync async, RespirarSessionBloc bloc) {
        async.elapse(const Duration(milliseconds: 6000));
        verify(() => playHaptic.execute(any(that: isA<NoParams>()))).called(1);

        async.elapse(const Duration(milliseconds: 1500 + 4500));
        verify(() => playHaptic.execute(any())).called(2);
      });
    });

    test('grows the Pausa hold by one second per cycle', () {
      runSession(mode: BreathingMode.pausa, (FakeAsync async, RespirarSessionBloc bloc) {
        async.elapse(const Duration(seconds: 8));
        expect(bloc.state.phaseType, BreathingPhaseType.hold);
        expect(bloc.state.phaseDuration, const Duration(seconds: 3));

        async.elapse(const Duration(seconds: 3 + 8));
        expect(bloc.state.phaseType, BreathingPhaseType.hold);
        expect(bloc.state.phaseDuration, const Duration(seconds: 4));

        async.elapse(const Duration(seconds: 4 + 8));
        expect(bloc.state.phaseDuration, const Duration(seconds: 5));
      });
    });

    test('caps the Pausa hold at twelve seconds', () {
      runSession(mode: BreathingMode.pausa, duration: SessionDuration.fifteenMinutes, (
        FakeAsync async,
        RespirarSessionBloc bloc,
      ) {
        final List<Duration> holds = <Duration>[];
        final StreamSubscription<RespirarSessionState> subscription = bloc.stream.listen((RespirarSessionState s) {
          if (s.phaseType == BreathingPhaseType.hold) holds.add(s.phaseDuration);
        });

        async.elapse(const Duration(minutes: 5));

        expect(holds.take(10).toList(), <Duration>[
          for (int seconds = 3; seconds <= 12; seconds++) Duration(seconds: seconds),
        ]);
        expect(holds.skip(10), everyElement(const Duration(seconds: 12)));
        unawaited(subscription.cancel());
      });
    });

    test('keeps breathing when the haptic pulse fails', () {
      when(() => playHaptic.execute(any())).thenThrow(Exception('no vibrator'));

      runSession((FakeAsync async, RespirarSessionBloc bloc) {
        async.elapse(const Duration(milliseconds: 6000 + 1500));

        expect(bloc.state.phaseType, BreathingPhaseType.exhale);
        expect(bloc.state.phaseNumber, 3);
      });
    });
  });

  group('ScreenTapped', () {
    test('freezes the phase and resumes it with the remaining time', () {
      runSession((FakeAsync async, RespirarSessionBloc bloc) {
        async.elapse(const Duration(seconds: 2));
        bloc.add(const ScreenTapped());
        async.flushMicrotasks();
        expect(bloc.state.isPaused, isTrue);

        async.elapse(const Duration(minutes: 1));
        expect(bloc.state.phaseNumber, 1);
        verifyNever(() => playHaptic.execute(any()));

        bloc.add(const ScreenTapped());
        async.flushMicrotasks();
        expect(bloc.state.isPaused, isFalse);

        async.elapse(const Duration(milliseconds: 3999));
        expect(bloc.state.phaseNumber, 1);
        async.elapse(const Duration(milliseconds: 1));
        expect(bloc.state.phaseNumber, 2);
      });
    });

    test('does not double-advance after a rapid pause and resume', () {
      runSession((FakeAsync async, RespirarSessionBloc bloc) {
        async.elapse(const Duration(milliseconds: 5999));
        bloc
          ..add(const ScreenTapped())
          ..add(const ScreenTapped());
        async.elapse(const Duration(milliseconds: 1));
        expect(bloc.state.phaseNumber, 2);

        async.elapse(const Duration(milliseconds: 1499));
        expect(bloc.state.phaseNumber, 2);
        async.elapse(const Duration(milliseconds: 1));
        expect(bloc.state.phaseNumber, 3);
      });
    });

    test('is ignored before the pattern has loaded', () {
      fakeAsync((FakeAsync async) {
        final Completer<BreathingPattern> completer = Completer<BreathingPattern>();
        when(() => getPattern.execute(any())).thenAnswer((_) => completer.future);
        final RespirarSessionBloc bloc = buildBloc();

        bloc
          ..add(const SessionStarted())
          ..add(const ScreenTapped());
        async.flushMicrotasks();
        expect(bloc.state.isPaused, isFalse);

        completer.complete(_compas);
        async.flushMicrotasks();
        expect(bloc.state.isPaused, isFalse);
        expect(bloc.state.phaseNumber, 1);

        unawaited(bloc.close());
        async.flushMicrotasks();
      });
    });
  });

  group('session end', () {
    test('finishes after the active duration, excluding pauses', () {
      runSession((FakeAsync async, RespirarSessionBloc bloc) {
        async.elapse(const Duration(minutes: 1));
        bloc.add(const ScreenTapped());
        async.elapse(const Duration(minutes: 10));
        bloc.add(const ScreenTapped());

        async.elapse(const Duration(seconds: 59, milliseconds: 999));
        expect(bloc.state.isFinished, isFalse);

        async.elapse(const Duration(milliseconds: 1));
        expect(bloc.state.isFinished, isTrue);
      });
    });

    test('opens the end screen only after the point has faded out', () {
      runSession((FakeAsync async, RespirarSessionBloc bloc) {
        async.elapse(const Duration(minutes: 2));
        expect(bloc.state.isFinished, isTrue);
        verifyNever(() => navigator.openSessionEnd());

        async.elapse(_fadeOut - const Duration(milliseconds: 1));
        verifyNever(() => navigator.openSessionEnd());

        async.elapse(const Duration(milliseconds: 1));
        verify(() => navigator.openSessionEnd()).called(1);
      });
    });

    test('stops the rhythm and ignores input once finished', () {
      runSession((FakeAsync async, RespirarSessionBloc bloc) {
        async.elapse(const Duration(minutes: 2));
        final int finalPhase = bloc.state.phaseNumber;
        clearInteractions(playHaptic);

        bloc
          ..add(const ScreenTapped())
          ..add(const ExitRequested());
        async.elapse(const Duration(minutes: 1));

        expect(bloc.state.phaseNumber, finalPhase);
        expect(bloc.state.isPaused, isFalse);
        expect(bloc.state.isConfirmingExit, isFalse);
        verifyNever(() => playHaptic.execute(any()));
        verifyNever(() => navigator.confirmLeaveSession());
      });
    });

    test('does not open the end screen when closed during the fade out', () {
      fakeAsync((FakeAsync async) {
        final RespirarSessionBloc bloc = buildBloc();
        bloc.add(const SessionStarted());
        async.elapse(const Duration(minutes: 2));
        expect(bloc.state.isFinished, isTrue);

        unawaited(bloc.close());
        async.elapse(_fadeOut * 2);

        verifyNever(() => navigator.openSessionEnd());
      });
    });
  });

  group('ExitRequested', () {
    test('pauses and asks for confirmation', () {
      runSession((FakeAsync async, RespirarSessionBloc bloc) {
        final Completer<bool?> completer = Completer<bool?>();
        when(() => navigator.confirmLeaveSession()).thenAnswer((_) => completer.future);

        bloc.add(const ExitRequested());
        async.flushMicrotasks();

        expect(bloc.state.isPaused, isTrue);
        expect(bloc.state.isConfirmingExit, isTrue);
        verify(() => navigator.confirmLeaveSession()).called(1);

        async.elapse(const Duration(minutes: 5));
        expect(bloc.state.phaseNumber, 1);
        expect(bloc.state.isFinished, isFalse);

        completer.complete(false);
        async.flushMicrotasks();
      });
    });

    test('leaves the session when confirmed', () {
      when(() => navigator.confirmLeaveSession()).thenAnswer((_) async => true);

      runSession((FakeAsync async, RespirarSessionBloc bloc) {
        bloc.add(const ExitRequested());
        async.flushMicrotasks();

        verifyInOrder(<void Function()>[
          () => navigator.confirmLeaveSession(),
          () => navigator.leaveSession(),
        ]);
      });
    });

    test('resumes a running session when the user stays', () {
      runSession((FakeAsync async, RespirarSessionBloc bloc) {
        final Completer<bool?> completer = Completer<bool?>();
        when(() => navigator.confirmLeaveSession()).thenAnswer((_) => completer.future);

        async.elapse(const Duration(seconds: 2));
        bloc.add(const ExitRequested());
        async.elapse(const Duration(seconds: 30));
        completer.complete(false);
        async.flushMicrotasks();

        expect(bloc.state.isConfirmingExit, isFalse);
        expect(bloc.state.isPaused, isFalse);
        verifyNever(() => navigator.leaveSession());

        async.elapse(const Duration(milliseconds: 3999));
        expect(bloc.state.phaseNumber, 1);
        async.elapse(const Duration(milliseconds: 1));
        expect(bloc.state.phaseNumber, 2);
      });
    });

    test('treats a dismissed confirmation as staying', () {
      when(() => navigator.confirmLeaveSession()).thenAnswer((_) async => null);

      runSession((FakeAsync async, RespirarSessionBloc bloc) {
        bloc.add(const ExitRequested());
        async.flushMicrotasks();

        expect(bloc.state.isConfirmingExit, isFalse);
        expect(bloc.state.isPaused, isFalse);
        verifyNever(() => navigator.leaveSession());
      });
    });

    test('keeps a paused session paused when the user stays', () {
      runSession((FakeAsync async, RespirarSessionBloc bloc) {
        bloc.add(const ScreenTapped());
        bloc.add(const ExitRequested());
        async.flushMicrotasks();

        expect(bloc.state.isConfirmingExit, isFalse);
        expect(bloc.state.isPaused, isTrue);

        async.elapse(const Duration(minutes: 1));
        expect(bloc.state.phaseNumber, 1);
      });
    });

    test('asks only once while the confirmation is open', () {
      runSession((FakeAsync async, RespirarSessionBloc bloc) {
        final Completer<bool?> completer = Completer<bool?>();
        when(() => navigator.confirmLeaveSession()).thenAnswer((_) => completer.future);

        bloc
          ..add(const ExitRequested())
          ..add(const ExitRequested());
        async.flushMicrotasks();

        verify(() => navigator.confirmLeaveSession()).called(1);
        completer.complete(false);
        async.flushMicrotasks();
      });
    });

    test('ignores taps while the confirmation is open', () {
      runSession((FakeAsync async, RespirarSessionBloc bloc) {
        final Completer<bool?> completer = Completer<bool?>();
        when(() => navigator.confirmLeaveSession()).thenAnswer((_) => completer.future);

        bloc.add(const ExitRequested());
        async.flushMicrotasks();
        bloc.add(const ScreenTapped());
        async.flushMicrotasks();

        expect(bloc.state.isPaused, isTrue);
        expect(bloc.state.isConfirmingExit, isTrue);
        completer.complete(false);
        async.flushMicrotasks();
      });
    });

    test('does not emit when closed while the confirmation is open', () {
      fakeAsync((FakeAsync async) {
        final Completer<bool?> completer = Completer<bool?>();
        when(() => navigator.confirmLeaveSession()).thenAnswer((_) => completer.future);

        final RespirarSessionBloc bloc = buildBloc();
        bloc.add(const SessionStarted());
        async.flushMicrotasks();
        bloc.add(const ExitRequested());
        async.flushMicrotasks();

        unawaited(bloc.close());
        async.flushMicrotasks();
        completer.complete(true);
        async.flushMicrotasks();

        verifyNever(() => navigator.leaveSession());
      });
    });
  });

  group('AppBackgrounded', () {
    test('pauses a running session', () {
      runSession((FakeAsync async, RespirarSessionBloc bloc) {
        bloc.add(const AppBackgrounded());
        async.flushMicrotasks();

        expect(bloc.state.isPaused, isTrue);
        async.elapse(const Duration(minutes: 5));
        expect(bloc.state.phaseNumber, 1);
        expect(bloc.state.isFinished, isFalse);
      });
    });

    test('does not resume on its own when the app returns', () {
      runSession((FakeAsync async, RespirarSessionBloc bloc) {
        bloc
          ..add(const AppBackgrounded())
          ..add(const AppBackgrounded());
        async.flushMicrotasks();

        expect(bloc.state.isPaused, isTrue);
      });
    });

    test('keeps the session paused after "Stay" when backgrounded during the confirmation', () {
      runSession((FakeAsync async, RespirarSessionBloc bloc) {
        final Completer<bool?> completer = Completer<bool?>();
        when(() => navigator.confirmLeaveSession()).thenAnswer((_) => completer.future);

        bloc.add(const ExitRequested());
        async.flushMicrotasks();
        bloc.add(const AppBackgrounded());
        async.flushMicrotasks();
        completer.complete(false);
        async.flushMicrotasks();

        expect(bloc.state.isConfirmingExit, isFalse);
        expect(bloc.state.isPaused, isTrue);
      });
    });
  });

  group('close', () {
    test('cancels the timers and releases the screen', () {
      fakeAsync((FakeAsync async) {
        final RespirarSessionBloc bloc = buildBloc();
        bloc.add(const SessionStarted());
        async.flushMicrotasks();
        clearInteractions(playHaptic);

        unawaited(bloc.close());
        async.elapse(const Duration(minutes: 5));

        verify(() => setScreenAwake.execute(any(that: awakeParams(enabled: false)))).called(1);
        verifyNever(() => playHaptic.execute(any()));
        verifyNever(() => navigator.openSessionEnd());
        expect(async.pendingTimers, isEmpty);
      });
    });
  });
}
