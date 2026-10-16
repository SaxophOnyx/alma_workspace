import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

BreathingPatternEntity _entity({
  String mode = 'pausa',
  List<BreathingPhaseEntity> phases = const <BreathingPhaseEntity>[
    BreathingPhaseEntity(type: 'inhale', durationMs: 4000),
    BreathingPhaseEntity(type: 'exhale', durationMs: 4000),
    BreathingPhaseEntity(type: 'hold', durationMs: 3000),
  ],
  HoldProgressionEntity? holdProgression = const HoldProgressionEntity(
    phaseIndex: 2,
    fromMs: 3000,
    toMs: 12000,
    stepMs: 1000,
  ),
}) {
  return BreathingPatternEntity(mode: mode, phases: phases, holdProgression: holdProgression);
}

void main() {
  group('fromEntity', () {
    test('maps mode, phases and hold progression', () {
      final BreathingPattern pattern = BreathingPatternMapper.fromEntity(_entity());

      expect(pattern.mode, BreathingMode.pausa);
      expect(
        pattern.phases.map((BreathingPhase p) => p.type).toList(),
        <BreathingPhaseType>[BreathingPhaseType.inhale, BreathingPhaseType.exhale, BreathingPhaseType.hold],
      );
      expect(
        pattern.phases.map((BreathingPhase p) => p.duration).toList(),
        const <Duration>[Duration(seconds: 4), Duration(seconds: 4), Duration(seconds: 3)],
      );
      final HoldProgression progression = pattern.holdProgression!;
      expect(progression.phaseIndex, 2);
      expect(progression.from, const Duration(seconds: 3));
      expect(progression.to, const Duration(seconds: 12));
      expect(progression.step, const Duration(seconds: 1));
    });

    test('maps every known mode', () {
      const Map<String, BreathingMode> modes = <String, BreathingMode>{
        'compas': BreathingMode.compas,
        'pausa': BreathingMode.pausa,
        'caminar': BreathingMode.caminar,
        'abrazo': BreathingMode.abrazo,
      };
      for (final MapEntry<String, BreathingMode> entry in modes.entries) {
        expect(BreathingPatternMapper.fromEntity(_entity(mode: entry.key)).mode, entry.value);
      }
    });

    test('keeps a null hold progression as null', () {
      expect(BreathingPatternMapper.fromEntity(_entity(holdProgression: null)).holdProgression, isNull);
    });

    test('keeps sub-second phase durations exact', () {
      final BreathingPattern pattern = BreathingPatternMapper.fromEntity(
        _entity(
          phases: const <BreathingPhaseEntity>[BreathingPhaseEntity(type: 'hold', durationMs: 1500)],
          holdProgression: null,
        ),
      );

      expect(pattern.phases.single.duration, const Duration(milliseconds: 1500));
    });

    test('throws FormatException for an unknown mode', () {
      expect(() => BreathingPatternMapper.fromEntity(_entity(mode: 'tango')), throwsFormatException);
    });

    test('throws FormatException for a mode with different casing', () {
      expect(() => BreathingPatternMapper.fromEntity(_entity(mode: 'Compas')), throwsFormatException);
    });

    test('throws FormatException for an unknown phase type', () {
      expect(
        () => BreathingPatternMapper.fromEntity(
          _entity(
            phases: const <BreathingPhaseEntity>[BreathingPhaseEntity(type: 'sigh', durationMs: 1000)],
            holdProgression: null,
          ),
        ),
        throwsFormatException,
      );
    });

    test('throws FormatException for an empty phase list', () {
      expect(
        () => BreathingPatternMapper.fromEntity(_entity(phases: const <BreathingPhaseEntity>[], holdProgression: null)),
        throwsFormatException,
      );
    });

    test('throws FormatException for a zero-length phase', () {
      expect(
        () => BreathingPatternMapper.fromEntity(
          _entity(
            phases: const <BreathingPhaseEntity>[BreathingPhaseEntity(type: 'inhale', durationMs: 0)],
            holdProgression: null,
          ),
        ),
        throwsFormatException,
      );
    });

    test('throws FormatException for a negative phase duration', () {
      expect(
        () => BreathingPatternMapper.fromEntity(
          _entity(
            phases: const <BreathingPhaseEntity>[BreathingPhaseEntity(type: 'inhale', durationMs: -1)],
            holdProgression: null,
          ),
        ),
        throwsFormatException,
      );
    });

    test('throws FormatException when the progression points past the last phase', () {
      expect(
        () => BreathingPatternMapper.fromEntity(
          _entity(
            holdProgression: const HoldProgressionEntity(phaseIndex: 3, fromMs: 3000, toMs: 12000, stepMs: 1000),
          ),
        ),
        throwsFormatException,
      );
    });

    test('throws FormatException when the progression index is negative', () {
      expect(
        () => BreathingPatternMapper.fromEntity(
          _entity(
            holdProgression: const HoldProgressionEntity(phaseIndex: -1, fromMs: 3000, toMs: 12000, stepMs: 1000),
          ),
        ),
        throwsFormatException,
      );
    });

    test('throws FormatException when the progression starts at zero', () {
      expect(
        () => BreathingPatternMapper.fromEntity(
          _entity(
            holdProgression: const HoldProgressionEntity(phaseIndex: 2, fromMs: 0, toMs: 12000, stepMs: 1000),
          ),
        ),
        throwsFormatException,
      );
    });

    test('throws FormatException when the progression shrinks', () {
      expect(
        () => BreathingPatternMapper.fromEntity(
          _entity(
            holdProgression: const HoldProgressionEntity(phaseIndex: 2, fromMs: 12000, toMs: 3000, stepMs: 1000),
          ),
        ),
        throwsFormatException,
      );
    });

    test('throws FormatException for a negative progression step', () {
      expect(
        () => BreathingPatternMapper.fromEntity(
          _entity(
            holdProgression: const HoldProgressionEntity(phaseIndex: 2, fromMs: 3000, toMs: 12000, stepMs: -1000),
          ),
        ),
        throwsFormatException,
      );
    });
  });
}
