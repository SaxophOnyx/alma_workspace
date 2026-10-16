import 'package:domain/domain.dart';
import 'package:test/test.dart';

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

void main() {
  group('durationOf', () {
    test('returns the phase duration for a pattern without progression', () {
      expect(_compas.durationOf(phaseIndex: 0, cycle: 0), const Duration(milliseconds: 6000));
      expect(_compas.durationOf(phaseIndex: 1, cycle: 0), const Duration(milliseconds: 1500));
      expect(_compas.durationOf(phaseIndex: 2, cycle: 0), const Duration(milliseconds: 4500));
    });

    test('does not change durations across cycles without progression', () {
      expect(_compas.durationOf(phaseIndex: 1, cycle: 50), const Duration(milliseconds: 1500));
    });

    test('starts the progressed phase at its "from" duration on the first cycle', () {
      expect(_pausa.durationOf(phaseIndex: 2, cycle: 0), const Duration(seconds: 3));
    });

    test('grows the progressed phase by one step per cycle', () {
      expect(_pausa.durationOf(phaseIndex: 2, cycle: 1), const Duration(seconds: 4));
      expect(_pausa.durationOf(phaseIndex: 2, cycle: 5), const Duration(seconds: 8));
    });

    test('caps the progressed phase at its "to" duration', () {
      expect(_pausa.durationOf(phaseIndex: 2, cycle: 9), const Duration(seconds: 12));
      expect(_pausa.durationOf(phaseIndex: 2, cycle: 10), const Duration(seconds: 12));
      expect(_pausa.durationOf(phaseIndex: 2, cycle: 1000), const Duration(seconds: 12));
    });

    test('leaves non-progressed phases of a progressed pattern untouched', () {
      expect(_pausa.durationOf(phaseIndex: 0, cycle: 7), const Duration(seconds: 4));
      expect(_pausa.durationOf(phaseIndex: 1, cycle: 7), const Duration(seconds: 4));
    });
  });

  group('SessionDuration', () {
    test('exposes the four spec durations in order', () {
      expect(
        SessionDuration.values.map((SessionDuration d) => d.value).toList(),
        const <Duration>[
          Duration(minutes: 2),
          Duration(minutes: 5),
          Duration(minutes: 10),
          Duration(minutes: 15),
        ],
      );
    });
  });
}
