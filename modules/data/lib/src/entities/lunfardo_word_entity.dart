import 'package:json_annotation/json_annotation.dart';

part 'lunfardo_word_entity.g.dart';

@JsonSerializable(createToJson: false)
class LunfardoWordEntity {
  final String id;
  final String word;
  final String meaning;
  final String etymology;

  const LunfardoWordEntity({
    required this.id,
    required this.word,
    required this.meaning,
    required this.etymology,
  });

  factory LunfardoWordEntity.fromJson(Map<String, dynamic> json) => _$LunfardoWordEntityFromJson(json);
}
