import 'package:domain/domain.dart';

LunfardoWord buildWord(String id, {String textId = 'yira_yira'}) {
  return LunfardoWord(
    id: id,
    word: id,
    pronunciation: '/$id/',
    meaning: 'meaning of $id',
    etymology: <String>['origin of $id', 'Lunfardo: $id'],
    example: WordExample(
      line: TextLine(segments: <TextSegment>[TextSegment(text: id, wordId: id)]),
      title: 'Yira, yira',
      year: 1930,
      textId: textId,
    ),
    related: const <String>[],
  );
}
