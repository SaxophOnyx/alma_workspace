import 'package:json_annotation/json_annotation.dart';

part 'quote_entity.g.dart';

@JsonSerializable(createToJson: false)
class QuoteEntity {
  final String line;
  final String title;
  final int year;
  final String textId;

  const QuoteEntity({
    required this.line,
    required this.title,
    required this.year,
    required this.textId,
  });

  factory QuoteEntity.fromJson(Map<String, dynamic> json) => _$QuoteEntityFromJson(json);
}
