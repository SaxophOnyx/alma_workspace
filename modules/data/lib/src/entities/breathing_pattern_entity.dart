import 'package:json_annotation/json_annotation.dart';

import 'breathing_phase_entity.dart';
import 'hold_progression_entity.dart';

part 'breathing_pattern_entity.g.dart';

@JsonSerializable(createToJson: false)
class BreathingPatternEntity {
  final String mode;
  final List<BreathingPhaseEntity> phases;
  final HoldProgressionEntity? holdProgression;

  const BreathingPatternEntity({
    required this.mode,
    required this.phases,
    this.holdProgression,
  });

  factory BreathingPatternEntity.fromJson(Map<String, dynamic> json) => _$BreathingPatternEntityFromJson(json);
}
