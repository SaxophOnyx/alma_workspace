import 'dart:async';

import 'package:clock/clock.dart';
import 'package:domain/domain.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../navigation/respirar_navigator.dart';

part 'respirar_session_event.dart';
part 'respirar_session_state.dart';

/// Drives the breathing rhythm.
///
/// Two timers run while the session is active: one for the current phase and one for the
/// remaining active session time. Pausing cancels both and keeps what is left, so paused time
/// never counts towards the session.
class RespirarSessionBloc extends Bloc<RespirarSessionEvent, RespirarSessionState> {
  final BreathingMode _mode;
  final SessionDuration _duration;
  final GetBreathingPatternUseCase _getBreathingPatternUseCase;
  final PlayPhaseHapticUseCase _playPhaseHapticUseCase;
  final SetScreenAwakeUseCase _setScreenAwakeUseCase;
  final RespirarNavigator _navigator;
  final Duration _fadeOutDuration;

  BreathingPattern? _pattern;
  int _patternPhaseIndex = 0;
  int _cycle = 0;

  Timer? _phaseTimer;
  Timer? _sessionTimer;
  // Timer ids let handlers ignore completions that were queued before a pause or phase change.
  int _phaseTimerId = 0;
  int _sessionTimerId = 0;
  Duration _phaseRemaining = Duration.zero;
  Duration _sessionRemaining = Duration.zero;
  DateTime _phaseResumedAt = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _sessionResumedAt = DateTime.fromMillisecondsSinceEpoch(0);

  bool _resumeAfterConfirmation = false;

  RespirarSessionBloc({
    required BreathingMode mode,
    required SessionDuration duration,
    required GetBreathingPatternUseCase getBreathingPatternUseCase,
    required PlayPhaseHapticUseCase playPhaseHapticUseCase,
    required SetScreenAwakeUseCase setScreenAwakeUseCase,
    required RespirarNavigator navigator,
    Duration fadeOutDuration = AppMotions.durationFadeOut,
  }) : _mode = mode,
       _duration = duration,
       _getBreathingPatternUseCase = getBreathingPatternUseCase,
       _playPhaseHapticUseCase = playPhaseHapticUseCase,
       _setScreenAwakeUseCase = setScreenAwakeUseCase,
       _navigator = navigator,
       _fadeOutDuration = fadeOutDuration,
       super(const RespirarSessionState()) {
    on<SessionStarted>(_onSessionStarted);
    on<ScreenTapped>(_onScreenTapped);
    on<ExitRequested>(_onExitRequested);
    on<AppBackgrounded>(_onAppBackgrounded);
    on<_PhaseCompleted>(_onPhaseCompleted);
    on<_SessionCompleted>(_onSessionCompleted);
  }

  bool get _isRunning => _pattern != null && !state.isFinished;

  Future<void> _onSessionStarted(SessionStarted event, Emitter<RespirarSessionState> emit) async {
    if (state.isLoading || _pattern != null) return;
    emit(state.copyWith(isLoading: true, error: null));

    final BreathingPattern pattern;
    try {
      pattern = await _getBreathingPatternUseCase.execute(GetBreathingPatternParams(mode: _mode));
    } on Exception catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, error: e));
      await _navigator.leaveSession();
      return;
    }
    if (isClosed) return;

    _pattern = pattern;
    _sessionRemaining = _duration.value;
    unawaited(_setScreenAwake(enabled: true));

    _startSessionTimer();
    // The very first phase has no transition, so no haptic pulse.
    _startPhase(emit);
  }

  void _onScreenTapped(ScreenTapped event, Emitter<RespirarSessionState> emit) {
    if (!_isRunning || state.isConfirmingExit) return;

    if (state.isPaused) {
      _resumeTimers();
      emit(state.copyWith(isPaused: false));
    } else {
      _pauseTimers();
      emit(state.copyWith(isPaused: true));
    }
  }

  Future<void> _onExitRequested(ExitRequested event, Emitter<RespirarSessionState> emit) async {
    if (!_isRunning || state.isConfirmingExit) return;

    _resumeAfterConfirmation = !state.isPaused;
    if (!state.isPaused) _pauseTimers();
    emit(state.copyWith(isPaused: true, isConfirmingExit: true));

    final bool? shouldLeave = await _navigator.confirmLeaveSession();
    if (isClosed) return;

    if (shouldLeave == true) {
      await _navigator.leaveSession();
      return;
    }

    if (_resumeAfterConfirmation) {
      _resumeTimers();
      emit(state.copyWith(isConfirmingExit: false, isPaused: false));
    } else {
      emit(state.copyWith(isConfirmingExit: false));
    }
  }

  void _onAppBackgrounded(AppBackgrounded event, Emitter<RespirarSessionState> emit) {
    if (!_isRunning) return;

    if (state.isConfirmingExit) {
      // Already paused; make sure "Stay" does not resume while the user is away.
      _resumeAfterConfirmation = false;
      return;
    }
    if (state.isPaused) return;

    _pauseTimers();
    emit(state.copyWith(isPaused: true));
  }

  void _onPhaseCompleted(_PhaseCompleted event, Emitter<RespirarSessionState> emit) {
    if (event.timerId != _phaseTimerId || !_isRunning || state.isPaused) return;

    final BreathingPattern pattern = _pattern!;
    _patternPhaseIndex++;
    if (_patternPhaseIndex >= pattern.phases.length) {
      _patternPhaseIndex = 0;
      _cycle++;
    }

    _startPhase(emit);
    unawaited(_playHaptic());
  }

  Future<void> _onSessionCompleted(_SessionCompleted event, Emitter<RespirarSessionState> emit) async {
    if (event.timerId != _sessionTimerId || !_isRunning || state.isPaused) return;

    _cancelTimers();
    emit(state.copyWith(isFinished: true));

    await Future<void>.delayed(_fadeOutDuration);
    if (isClosed) return;

    await _navigator.openSessionEnd();
  }

  void _startPhase(Emitter<RespirarSessionState> emit) {
    final BreathingPattern pattern = _pattern!;
    final Duration phaseDuration = pattern.durationOf(phaseIndex: _patternPhaseIndex, cycle: _cycle);

    _phaseRemaining = phaseDuration;
    _startPhaseTimer();

    emit(
      state.copyWith(
        isLoading: false,
        phaseType: pattern.phases[_patternPhaseIndex].type,
        phaseDuration: phaseDuration,
        phaseNumber: state.phaseNumber + 1,
      ),
    );
  }

  void _startPhaseTimer() {
    _phaseTimer?.cancel();
    final int timerId = ++_phaseTimerId;
    _phaseResumedAt = clock.now();
    _phaseTimer = Timer(_phaseRemaining, () => add(_PhaseCompleted(timerId)));
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    final int timerId = ++_sessionTimerId;
    _sessionResumedAt = clock.now();
    _sessionTimer = Timer(_sessionRemaining, () => add(_SessionCompleted(timerId)));
  }

  void _pauseTimers() {
    final DateTime now = clock.now();
    _phaseRemaining = _nonNegative(_phaseRemaining - now.difference(_phaseResumedAt));
    _sessionRemaining = _nonNegative(_sessionRemaining - now.difference(_sessionResumedAt));
    _cancelTimers();
  }

  void _resumeTimers() {
    _startSessionTimer();
    _startPhaseTimer();
  }

  void _cancelTimers() {
    _phaseTimer?.cancel();
    _sessionTimer?.cancel();
    _phaseTimer = null;
    _sessionTimer = null;
    _phaseTimerId++;
    _sessionTimerId++;
  }

  Duration _nonNegative(Duration duration) => duration.isNegative ? Duration.zero : duration;

  Future<void> _playHaptic() async {
    try {
      await _playPhaseHapticUseCase.execute(const NoParams());
    } on Exception catch (_) {
      // A missed pulse must not interrupt the breathing.
    }
  }

  Future<void> _setScreenAwake({required bool enabled}) async {
    try {
      await _setScreenAwakeUseCase.execute(SetScreenAwakeParams(enabled: enabled));
    } on Exception catch (_) {
      // The session works without it; the screen may just dim.
    }
  }

  @override
  Future<void> close() {
    _cancelTimers();
    unawaited(_setScreenAwake(enabled: false));
    return super.close();
  }
}
