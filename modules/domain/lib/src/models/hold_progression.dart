/// Grows the phase at [phaseIndex] by [step] every cycle, from [from] up to [to].
class HoldProgression {
  final int phaseIndex;
  final Duration from;
  final Duration to;
  final Duration step;

  const HoldProgression({
    required this.phaseIndex,
    required this.from,
    required this.to,
    required this.step,
  });
}
