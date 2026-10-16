part of 'leer_reading_bloc.dart';

final class LeerReadingState {
  final bool isLoading;
  final TangoText? text;
  final int stanzaIndex;
  final int lineIndex;
  final ReadingPhase phase;
  final bool isNavigating;

  /// The Lunfardo word whose annotation is open; marked in the line while it is.
  final String? activeWordId;
  final Exception? error;

  const LeerReadingState({
    this.isLoading = true,
    this.text,
    this.stanzaIndex = 0,
    this.lineIndex = 0,
    this.phase = ReadingPhase.line,
    this.isNavigating = false,
    this.activeWordId,
    this.error,
  });

  TextLine? get currentLine {
    final TangoText? text = this.text;
    if (text == null || phase != ReadingPhase.line) return null;
    return text.stanzas[stanzaIndex].lines[lineIndex];
  }

  bool get isEnding => phase == ReadingPhase.endSilence || phase == ReadingPhase.end;

  static const Object _unset = Object();

  LeerReadingState copyWith({
    bool? isLoading,
    Object? text = _unset,
    int? stanzaIndex,
    int? lineIndex,
    ReadingPhase? phase,
    bool? isNavigating,
    Object? activeWordId = _unset,
    Object? error = _unset,
  }) {
    return LeerReadingState(
      isLoading: isLoading ?? this.isLoading,
      text: identical(text, _unset) ? this.text : text as TangoText?,
      stanzaIndex: stanzaIndex ?? this.stanzaIndex,
      lineIndex: lineIndex ?? this.lineIndex,
      phase: phase ?? this.phase,
      isNavigating: isNavigating ?? this.isNavigating,
      activeWordId: identical(activeWordId, _unset) ? this.activeWordId : activeWordId as String?,
      error: identical(error, _unset) ? this.error : error as Exception?,
    );
  }
}
