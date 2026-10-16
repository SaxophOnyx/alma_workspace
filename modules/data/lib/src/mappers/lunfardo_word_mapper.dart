import 'package:domain/domain.dart';

import '../entities/entities.dart';
import 'text_mapper.dart';

final class LunfardoWordMapper {
  const LunfardoWordMapper._();

  static LunfardoWord fromEntity(LunfardoWordEntity entity) {
    if (entity.id.isEmpty) {
      throw FormatException('Lunfardo word id is empty', entity.word);
    }
    if (entity.word.trim().isEmpty) {
      throw FormatException('Lunfardo word is empty', entity.id);
    }
    if (entity.pronunciation.trim().isEmpty) {
      throw FormatException('Lunfardo word pronunciation is empty', entity.id);
    }
    if (entity.meaning.trim().isEmpty) {
      throw FormatException('Lunfardo word meaning is empty', entity.id);
    }
    if (entity.etymology.isEmpty || entity.etymology.any((String step) => step.trim().isEmpty)) {
      throw FormatException('Lunfardo word etymology has an empty step', entity.id);
    }
    if (entity.related.any((String related) => related.trim().isEmpty)) {
      throw FormatException('Lunfardo word has an empty related word', entity.id);
    }

    return LunfardoWord(
      id: entity.id,
      word: entity.word,
      pronunciation: entity.pronunciation,
      meaning: entity.meaning,
      etymology: List<String>.unmodifiable(entity.etymology),
      example: _exampleFromEntity(entity.example, entity.id),
      related: List<String>.unmodifiable(entity.related),
    );
  }

  static WordExample _exampleFromEntity(WordExampleEntity entity, String wordId) {
    if (entity.title.trim().isEmpty) {
      throw FormatException('Word example title is empty', wordId);
    }
    if (entity.textId.isEmpty) {
      throw FormatException('Word example text id is empty', wordId);
    }

    final TextLine line = TextMapper.lineFromMarkup(entity.line);
    if (!line.segments.any((TextSegment segment) => segment.wordId == wordId)) {
      throw FormatException('Word example line does not mark the word', entity.line);
    }

    return WordExample(
      line: line,
      title: entity.title,
      year: entity.year,
      textId: entity.textId,
    );
  }
}
