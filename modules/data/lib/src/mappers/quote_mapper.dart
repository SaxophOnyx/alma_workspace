import 'package:domain/domain.dart';

import '../entities/entities.dart';

final class QuoteMapper {
  const QuoteMapper._();

  static Quote fromEntity(QuoteEntity entity) {
    if (entity.line.trim().isEmpty) {
      throw FormatException('Quote line is empty', entity.textId);
    }
    if (entity.textId.isEmpty) {
      throw FormatException('Quote text id is empty', entity.title);
    }

    return Quote(
      line: entity.line,
      title: entity.title,
      year: entity.year,
      textId: entity.textId,
    );
  }
}
