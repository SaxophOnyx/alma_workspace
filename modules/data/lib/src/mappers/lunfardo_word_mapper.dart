import 'package:domain/domain.dart';

import '../entities/entities.dart';

final class LunfardoWordMapper {
  const LunfardoWordMapper._();

  static LunfardoWord fromEntity(LunfardoWordEntity entity) {
    if (entity.id.isEmpty) {
      throw FormatException('Lunfardo word id is empty', entity.word);
    }
    if (entity.word.trim().isEmpty) {
      throw FormatException('Lunfardo word is empty', entity.id);
    }
    if (entity.meaning.trim().isEmpty) {
      throw FormatException('Lunfardo word meaning is empty', entity.id);
    }
    if (entity.etymology.trim().isEmpty) {
      throw FormatException('Lunfardo word etymology is empty', entity.id);
    }

    return LunfardoWord(
      id: entity.id,
      word: entity.word,
      meaning: entity.meaning,
      etymology: entity.etymology,
    );
  }
}
