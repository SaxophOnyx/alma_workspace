import 'dart:async';

import 'package:domain/domain.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../navigation/leer_navigator.dart';
import '../misc/reading_phase.dart';

part 'leer_reading_event.dart';
part 'leer_reading_state.dart';

/// Silences (between stanzas, after the last line) run on a timer so taps that land during them
/// are ignored instead of queued.
class LeerReadingBloc extends Bloc<LeerReadingEvent, LeerReadingState> {
  final String _textId;
  final GetTextUseCase _getTextUseCase;
  final LeerNavigator _navigator;
  final Duration _stanzaPauseDuration;
  final Duration _endSilenceDuration;

  Timer? _silenceTimer;

  LeerReadingBloc({
    required String textId,
    required GetTextUseCase getTextUseCase,
    required LeerNavigator navigator,
    Duration stanzaPauseDuration = AppMotions.silenceStanza,
    Duration endSilenceDuration = AppMotions.silenceLong,
  }) : _textId = textId,
       _getTextUseCase = getTextUseCase,
       _navigator = navigator,
       _stanzaPauseDuration = stanzaPauseDuration,
       _endSilenceDuration = endSilenceDuration,
       super(const LeerReadingState()) {
    on<ReadingStarted>(_onStarted);
    on<ScreenTapped>(_onScreenTapped);
    on<WordPressed>(_onWordPressed);
    on<AnotherTextPressed>(_onAnotherTextPressed);
    on<BreathePressed>(_onBreathePressed);
    on<HomePressed>(_onHomePressed);
    on<TextEndBackPressed>(_onTextEndBackPressed);
    on<_StanzaPauseCompleted>(_onStanzaPauseCompleted);
    on<_EndSilenceCompleted>(_onEndSilenceCompleted);
  }

  Future<void> _onStarted(ReadingStarted event, Emitter<LeerReadingState> emit) async {
    if (state.text != null) return;
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final TangoText text = await _getTextUseCase.execute(GetTextParams(textId: _textId));
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, text: text, stanzaIndex: 0, lineIndex: 0, phase: ReadingPhase.line));
    } on Exception catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, text: null, error: e));
    }
  }

  void _onScreenTapped(ScreenTapped event, Emitter<LeerReadingState> emit) {
    final TangoText? text = state.text;
    if (text == null || state.phase != ReadingPhase.line || state.isNavigating) return;

    final List<TextLine> lines = text.stanzas[state.stanzaIndex].lines;
    if (state.lineIndex + 1 < lines.length) {
      emit(state.copyWith(lineIndex: state.lineIndex + 1));
      return;
    }

    if (state.stanzaIndex + 1 < text.stanzas.length) {
      emit(state.copyWith(phase: ReadingPhase.stanzaPause));
      _startSilence(_stanzaPauseDuration, const _StanzaPauseCompleted());
      return;
    }

    emit(state.copyWith(phase: ReadingPhase.endSilence));
    _startSilence(_endSilenceDuration, const _EndSilenceCompleted());
  }

  void _onStanzaPauseCompleted(_StanzaPauseCompleted event, Emitter<LeerReadingState> emit) {
    if (state.phase != ReadingPhase.stanzaPause) return;
    emit(state.copyWith(stanzaIndex: state.stanzaIndex + 1, lineIndex: 0, phase: ReadingPhase.line));
  }

  void _onEndSilenceCompleted(_EndSilenceCompleted event, Emitter<LeerReadingState> emit) {
    if (state.phase != ReadingPhase.endSilence) return;
    emit(state.copyWith(phase: ReadingPhase.end));
  }

  Future<void> _onWordPressed(WordPressed event, Emitter<LeerReadingState> emit) async {
    if (state.phase != ReadingPhase.line || state.isNavigating) return;
    emit(state.copyWith(isNavigating: true));

    try {
      await _navigator.openWordAnnotation(event.wordId);
    } on Exception catch (_) {
      // Stay usable; the user can tap again.
    }
    if (isClosed) return;

    emit(state.copyWith(isNavigating: false));
  }

  Future<void> _onAnotherTextPressed(AnotherTextPressed event, Emitter<LeerReadingState> emit) {
    return _navigateFromEnd(emit, _navigator.openTextList);
  }

  Future<void> _onBreathePressed(BreathePressed event, Emitter<LeerReadingState> emit) {
    return _navigateFromEnd(emit, _navigator.breatheWithText);
  }

  Future<void> _onHomePressed(HomePressed event, Emitter<LeerReadingState> emit) {
    return _navigateFromEnd(emit, _navigator.openHome);
  }

  Future<void> _onTextEndBackPressed(TextEndBackPressed event, Emitter<LeerReadingState> emit) async {
    if (!state.isEnding || state.isNavigating) return;
    emit(state.copyWith(isNavigating: true));

    _silenceTimer?.cancel();
    await _navigator.openTextList();
  }

  Future<void> _navigateFromEnd(Emitter<LeerReadingState> emit, Future<void> Function() navigate) async {
    if (state.phase != ReadingPhase.end || state.isNavigating) return;
    emit(state.copyWith(isNavigating: true));

    try {
      await navigate();
    } on Exception catch (_) {
      // Stay usable; the user can tap again.
    }
    if (isClosed) return;

    emit(state.copyWith(isNavigating: false));
  }

  void _startSilence(Duration duration, LeerReadingEvent completion) {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(duration, () {
      if (!isClosed) add(completion);
    });
  }

  @override
  Future<void> close() {
    _silenceTimer?.cancel();
    return super.close();
  }
}
