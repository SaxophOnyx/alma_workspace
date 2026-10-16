import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

LunfardoWordEntity _entity({
  String id = 'grela',
  String word = 'grela',
  String pronunciation = "/'ɣɾe.la/",
  String meaning = 'fickle fate',
  List<String> etymology = const <String>['Italian grilla → "cricket"', 'Lunfardo: "fickle fate"'],
  String line = 'que es {grela}, te deja',
  String title = 'Yira, yira',
  int year = 1930,
  String textId = 'yira_yira',
  List<String> related = const <String>['suerte', 'yeta'],
}) {
  return LunfardoWordEntity(
    id: id,
    word: word,
    pronunciation: pronunciation,
    meaning: meaning,
    etymology: etymology,
    example: WordExampleEntity(line: line, title: title, year: year, textId: textId),
    related: related,
  );
}

void main() {
  group('fromEntity', () {
    test('maps every field', () {
      final LunfardoWord word = LunfardoWordMapper.fromEntity(_entity());

      expect(word.id, 'grela');
      expect(word.word, 'grela');
      expect(word.pronunciation, "/'ɣɾe.la/");
      expect(word.meaning, 'fickle fate');
      expect(word.etymology, <String>['Italian grilla → "cricket"', 'Lunfardo: "fickle fate"']);
      expect(word.related, <String>['suerte', 'yeta']);
      expect(word.example.title, 'Yira, yira');
      expect(word.example.year, 1930);
      expect(word.example.textId, 'yira_yira');
    });

    test('parses the example line into segments with the word marked', () {
      final LunfardoWord word = LunfardoWordMapper.fromEntity(_entity());

      expect(word.example.line.text, 'que es grela, te deja');
      expect(
        word.example.line.segments.map((TextSegment s) => (s.text, s.wordId)).toList(),
        <(String, String?)>[('que es ', null), ('grela', 'grela'), (', te deja', null)],
      );
    });

    test('accepts an example that marks an inflected surface form', () {
      final LunfardoWord word = LunfardoWordMapper.fromEntity(
        _entity(id: 'morfar', word: 'morfar', line: 'y el {morfo|morfar} no alcanza'),
      );

      expect(word.example.line.segments[1].text, 'morfo');
      expect(word.example.line.segments[1].wordId, 'morfar');
    });

    test('accepts a single-step etymology', () {
      final LunfardoWord word = LunfardoWordMapper.fromEntity(_entity(etymology: <String>['Italian grilla']));

      expect(word.etymology, <String>['Italian grilla']);
    });

    test('accepts an empty related list', () {
      expect(LunfardoWordMapper.fromEntity(_entity(related: <String>[])).related, isEmpty);
    });

    test('throws FormatException for an empty id', () {
      expect(() => LunfardoWordMapper.fromEntity(_entity(id: '')), throwsFormatException);
    });

    test('throws FormatException for a blank word', () {
      expect(() => LunfardoWordMapper.fromEntity(_entity(word: '  ')), throwsFormatException);
    });

    test('throws FormatException for a blank pronunciation', () {
      expect(() => LunfardoWordMapper.fromEntity(_entity(pronunciation: ' ')), throwsFormatException);
    });

    test('throws FormatException for a blank meaning', () {
      expect(() => LunfardoWordMapper.fromEntity(_entity(meaning: '')), throwsFormatException);
    });

    test('throws FormatException for an empty etymology chain', () {
      expect(() => LunfardoWordMapper.fromEntity(_entity(etymology: <String>[])), throwsFormatException);
    });

    test('throws FormatException for a blank etymology step', () {
      expect(
        () => LunfardoWordMapper.fromEntity(_entity(etymology: <String>['Italian grilla', ' '])),
        throwsFormatException,
      );
    });

    test('throws FormatException for a blank related word', () {
      expect(() => LunfardoWordMapper.fromEntity(_entity(related: <String>['suerte', ''])), throwsFormatException);
    });

    test('throws FormatException when the example line does not mark the word', () {
      expect(() => LunfardoWordMapper.fromEntity(_entity(line: 'que es grela, te deja')), throwsFormatException);
    });

    test('throws FormatException when the example line marks only another word', () {
      expect(() => LunfardoWordMapper.fromEntity(_entity(line: 'que es {yeta}, te deja')), throwsFormatException);
    });

    test('throws FormatException for malformed example markup', () {
      expect(() => LunfardoWordMapper.fromEntity(_entity(line: 'que es {grela, te deja')), throwsFormatException);
    });

    test('throws FormatException for a blank example line', () {
      expect(() => LunfardoWordMapper.fromEntity(_entity(line: ' ')), throwsFormatException);
    });

    test('throws FormatException for a blank example title', () {
      expect(() => LunfardoWordMapper.fromEntity(_entity(title: '')), throwsFormatException);
    });

    test('throws FormatException for an empty example text id', () {
      expect(() => LunfardoWordMapper.fromEntity(_entity(textId: '')), throwsFormatException);
    });
  });
}
