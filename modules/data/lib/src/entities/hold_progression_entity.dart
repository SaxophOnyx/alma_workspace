import 'package:json_annotation/json_annotation.dart';

part 'hold_progression_entity.g.dart';

@JsonSerializable(createToJson: false)
class HoldProgressionEntity {
  final int phaseIndex;
  final int fromMs;
  final int toMs;
  final int stepMs;

  const HoldProgressionEntity({
    required this.phaseIndex,
    required this.fromMs,
    required this.toMs,
    required this.stepMs,
  });

  factory HoldProgressionEntity.fromJson(Map<String, dynamic> json) => _$HoldProgressionEntityFromJson(json);
}
