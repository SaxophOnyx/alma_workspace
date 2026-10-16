import 'package:json_annotation/json_annotation.dart';

import 'word_example_entity.dart';

part 'lunfardo_word_entity.g.dart';

@JsonSerializable(createToJson: false)
class LunfardoWordEntity {
  final String id;
  final String word;
  final String pronunciation;
  final String meaning;

  /// Etymology chain, from the oldest source to the Lunfardo sense.
  final List<String> etymology;
  final WordExampleEntity example;
  final List<String> related;

  const LunfardoWordEntity({
    required this.id,
    required this.word,
    required this.pronunciation,
    required this.meaning,
    required this.etymology,
    required this.example,
    required this.related,
  });

  factory LunfardoWordEntity.fromJson(Map<String, dynamic> json) => _$LunfardoWordEntityFromJson(json);
}
