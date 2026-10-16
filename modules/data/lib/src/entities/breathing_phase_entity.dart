import 'package:json_annotation/json_annotation.dart';

part 'breathing_phase_entity.g.dart';

@JsonSerializable(createToJson: false)
class BreathingPhaseEntity {
  final String type;
  final int durationMs;

  const BreathingPhaseEntity({
    required this.type,
    required this.durationMs,
  });

  factory BreathingPhaseEntity.fromJson(Map<String, dynamic> json) => _$BreathingPhaseEntityFromJson(json);
}
