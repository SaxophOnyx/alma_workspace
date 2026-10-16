import 'package:json_annotation/json_annotation.dart';

part 'word_example_entity.g.dart';

@JsonSerializable(createToJson: false)
class WordExampleEntity {
  /// Raw tango line; the word is marked inline as `{word}` or `{surface|wordId}`.
  final String line;
  final String title;
  final int year;
  final String textId;

  const WordExampleEntity({
    required this.line,
    required this.title,
    required this.year,
    required this.textId,
  });

  factory WordExampleEntity.fromJson(Map<String, dynamic> json) => _$WordExampleEntityFromJson(json);
}
