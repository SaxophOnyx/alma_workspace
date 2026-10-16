part of 'respirar_session_bloc.dart';

final class RespirarSessionState {
  final bool isLoading;
  final BreathingPhaseType? phaseType;
  final Duration phaseDuration;

  /// Increments with every phase that starts, so repeated phase types are still distinguishable.
  final int phaseNumber;
  final bool isPaused;
  final bool isConfirmingExit;
  final bool isFinished;
  final Exception? error;

  const RespirarSessionState({
    this.isLoading = false,
    this.phaseType,
    this.phaseDuration = Duration.zero,
    this.phaseNumber = 0,
    this.isPaused = false,
    this.isConfirmingExit = false,
    this.isFinished = false,
    this.error,
  });

  static const Object _unset = Object();

  RespirarSessionState copyWith({
    bool? isLoading,
    Object? phaseType = _unset,
    Duration? phaseDuration,
    int? phaseNumber,
    bool? isPaused,
    bool? isConfirmingExit,
    bool? isFinished,
    Object? error = _unset,
  }) {
    return RespirarSessionState(
      isLoading: isLoading ?? this.isLoading,
      phaseType: identical(phaseType, _unset) ? this.phaseType : phaseType as BreathingPhaseType?,
      phaseDuration: phaseDuration ?? this.phaseDuration,
      phaseNumber: phaseNumber ?? this.phaseNumber,
      isPaused: isPaused ?? this.isPaused,
      isConfirmingExit: isConfirmingExit ?? this.isConfirmingExit,
      isFinished: isFinished ?? this.isFinished,
      error: identical(error, _unset) ? this.error : error as Exception?,
    );
  }
}
