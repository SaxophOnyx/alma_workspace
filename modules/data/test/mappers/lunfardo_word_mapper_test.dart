import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

LunfardoWordEntity _entity({
  String id = 'grela',
  String word = 'grela',
  String meaning = 'fickle fate',
  String etymology = 'Italian grilla',
}) {
  return LunfardoWordEntity(id: id, word: word, meaning: meaning, etymology: etymology);
}

void main() {
  group('fromEntity', () {
    test('maps every field', () {
      final LunfardoWord word = LunfardoWordMapper.fromEntity(_entity());

      expect(word.id, 'grela');
      expect(word.word, 'grela');
      expect(word.meaning, 'fickle fate');
      expect(word.etymology, 'Italian grilla');
    });

    test('throws FormatException for an empty id', () {
      expect(() => LunfardoWordMapper.fromEntity(_entity(id: '')), throwsFormatException);
    });

    test('throws FormatException for a blank word', () {
      expect(() => LunfardoWordMapper.fromEntity(_entity(word: '  ')), throwsFormatException);
    });

    test('throws FormatException for a blank meaning', () {
      expect(() => LunfardoWordMapper.fromEntity(_entity(meaning: '')), throwsFormatException);
    });

    test('throws FormatException for a blank etymology', () {
      expect(() => LunfardoWordMapper.fromEntity(_entity(etymology: ' ')), throwsFormatException);
    });
  });
}
