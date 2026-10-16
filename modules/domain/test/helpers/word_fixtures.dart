import 'package:domain/domain.dart';

/// Builds a complete [LunfardoWord] whose example line marks the word itself.
LunfardoWord buildWord(
  String id, {
  String? meaning,
  List<String>? etymology,
  List<String> related = const <String>[],
}) {
  return LunfardoWord(
    id: id,
    word: id,
    pronunciation: '/$id/',
    meaning: meaning ?? 'meaning of $id',
    etymology: etymology ?? <String>['origin of $id', 'Lunfardo: $id'],
    example: WordExample(
      line: TextLine(
        segments: <TextSegment>[
          const TextSegment(text: 'y el '),
          TextSegment(text: id, wordId: id),
          const TextSegment(text: ' se fue'),
        ],
      ),
      title: 'Title of $id',
      year: 1930,
      textId: 'text_$id',
    ),
    related: related,
  );
}
