import 'package:json_annotation/json_annotation.dart';

part 'text_entity.g.dart';

@JsonSerializable(createToJson: false)
class TextEntity {
  final String id;
  final String title;
  final String author;
  final int year;
  final String context;

  /// Stanzas of raw lines; Lunfardo words are marked inline as `{word}` or `{surface|wordId}`.
  final List<List<String>> stanzas;

  const TextEntity({
    required this.id,
    required this.title,
    required this.author,
    required this.year,
    required this.context,
    required this.stanzas,
  });

  factory TextEntity.fromJson(Map<String, dynamic> json) => _$TextEntityFromJson(json);
}
