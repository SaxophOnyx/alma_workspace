import 'package:domain/domain.dart';

import '../entities/entities.dart';

final class BreathingPatternMapper {
  const BreathingPatternMapper._();

  static BreathingPattern fromEntity(BreathingPatternEntity entity) {
    final BreathingMode? mode = BreathingMode.values.asNameMap()[entity.mode];
    if (mode == null) {
      throw FormatException('Unknown breathing mode', entity.mode);
    }
    if (entity.phases.isEmpty) {
      throw FormatException('Breathing pattern has no phases', entity.mode);
    }

    final List<BreathingPhase> phases = entity.phases.map(_phaseFromEntity).toList();
    final HoldProgressionEntity? progression = entity.holdProgression;

    return BreathingPattern(
      mode: mode,
      phases: phases,
      holdProgression: progression == null ? null : _progressionFromEntity(progression, phases.length),
    );
  }

  static BreathingPhase _phaseFromEntity(BreathingPhaseEntity entity) {
    final BreathingPhaseType? type = BreathingPhaseType.values.asNameMap()[entity.type];
    if (type == null) {
      throw FormatException('Unknown breathing phase type', entity.type);
    }
    // A zero-length phase would make the session loop spin without progressing.
    if (entity.durationMs <= 0) {
      throw FormatException('Breathing phase duration must be positive', entity.durationMs);
    }

    return BreathingPhase(
      type: type,
      duration: Duration(milliseconds: entity.durationMs),
    );
  }

  static HoldProgression _progressionFromEntity(HoldProgressionEntity entity, int phaseCount) {
    if (entity.phaseIndex < 0 || entity.phaseIndex >= phaseCount) {
      throw FormatException('Hold progression points outside the phase list', entity.phaseIndex);
    }
    if (entity.fromMs <= 0 || entity.toMs < entity.fromMs || entity.stepMs < 0) {
      throw const FormatException('Hold progression must grow from a positive duration');
    }

    return HoldProgression(
      phaseIndex: entity.phaseIndex,
      from: Duration(milliseconds: entity.fromMs),
      to: Duration(milliseconds: entity.toMs),
      step: Duration(milliseconds: entity.stepMs),
    );
  }
}
