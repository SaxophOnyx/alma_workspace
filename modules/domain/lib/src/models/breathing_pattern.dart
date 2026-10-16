import 'breathing_mode.dart';
import 'breathing_phase.dart';
import 'hold_progression.dart';

class BreathingPattern {
  final BreathingMode mode;
  final List<BreathingPhase> phases;
  final HoldProgression? holdProgression;

  const BreathingPattern({
    required this.mode,
    required this.phases,
    this.holdProgression,
  });

  /// Duration of the phase at [phaseIndex] during the zero-based [cycle].
  Duration durationOf({required int phaseIndex, required int cycle}) {
    final HoldProgression? progression = holdProgression;
    if (progression == null || progression.phaseIndex != phaseIndex) {
      return phases[phaseIndex].duration;
    }

    final Duration grown = progression.from + progression.step * cycle;
    return grown > progression.to ? progression.to : grown;
  }
}
