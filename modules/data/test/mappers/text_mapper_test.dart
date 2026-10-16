import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

TextEntity _entity({
  String id = 'yira_yira',
  String title = 'Yira, yira',
  String author = 'Enrique Santos Discépolo',
  int year = 1930,
  String context = 'Argentina after the 1930 coup.',
  List<List<String>> stanzas = const <List<String>>[
    <String>['Y si un día la suerte,', 'que es {grela}, te deja,'],
    <String>['vas a ver'],
  ],
}) {
  return TextEntity(id: id, title: title, author: author, year: year, context: context, stanzas: stanzas);
}

List<TextSegment> _segments(String line) {
  return TextMapper.fromEntity(
    _entity(
      stanzas: <List<String>>[
        <String>[line],
      ],
    ),
  ).stanzas.single.lines.single.segments;
}

Matcher _segment(String text, [String? wordId]) {
  return isA<TextSegment>()
      .having((TextSegment s) => s.text, 'text', text)
      .having((TextSegment s) => s.wordId, 'wordId', wordId);
}

void main() {
  group('fromEntity', () {
    test('maps every field and keeps stanza and line order', () {
      final TangoText text = TextMapper.fromEntity(_entity());

      expect(text.id, 'yira_yira');
      expect(text.title, 'Yira, yira');
      expect(text.author, 'Enrique Santos Discépolo');
      expect(text.year, 1930);
      expect(text.context, 'Argentina after the 1930 coup.');
      expect(text.stanzas, hasLength(2));
      expect(text.stanzas[0].lines.map((TextLine l) => l.text).toList(), <String>[
        'Y si un día la suerte,',
        'que es grela, te deja,',
      ]);
      expect(text.stanzas[1].lines.single.text, 'vas a ver');
    });

    test('throws FormatException for an empty id', () {
      expect(() => TextMapper.fromEntity(_entity(id: '')), throwsFormatException);
    });

    test('throws FormatException for a blank title', () {
      expect(() => TextMapper.fromEntity(_entity(title: '  ')), throwsFormatException);
    });

    test('throws FormatException for a blank author', () {
      expect(() => TextMapper.fromEntity(_entity(author: '')), throwsFormatException);
    });

    test('throws FormatException for a blank context', () {
      expect(() => TextMapper.fromEntity(_entity(context: ' \n ')), throwsFormatException);
    });

    test('throws FormatException when there are no stanzas', () {
      expect(() => TextMapper.fromEntity(_entity(stanzas: <List<String>>[])), throwsFormatException);
    });

    test('throws FormatException for an empty stanza', () {
      expect(
        () => TextMapper.fromEntity(
          _entity(
            stanzas: <List<String>>[
              <String>['uno'],
              <String>[],
            ],
          ),
        ),
        throwsFormatException,
      );
    });

    test('throws FormatException for a blank line', () {
      expect(() => _segments('   '), throwsFormatException);
    });
  });

  group('line markup', () {
    test('a line without markup is a single plain segment', () {
      expect(_segments('vas a ver'), <Matcher>[_segment('vas a ver')]);
    });

    test('{word} becomes a Lunfardo segment whose id is the lowercased word', () {
      expect(_segments('que es {grela}, te deja,'), <Matcher>[
        _segment('que es '),
        _segment('grela', 'grela'),
        _segment(', te deja,'),
      ]);
    });

    test('{Word} at the start of a line keeps its casing but lowercases the id', () {
      expect(_segments('{Mina} querida'), <Matcher>[
        _segment('Mina', 'mina'),
        _segment(' querida'),
      ]);
    });

    test('{surface|id} keeps the surface text and uses the explicit id', () {
      expect(_segments('Ya no {morfo|morfar} con ganas,'), <Matcher>[
        _segment('Ya no '),
        _segment('morfo', 'morfar'),
        _segment(' con ganas,'),
      ]);
    });

    test('keeps accented ids unchanged', () {
      expect(_segments('su perfume {fané}.'), <Matcher>[
        _segment('su perfume '),
        _segment('fané', 'fané'),
        _segment('.'),
      ]);
    });

    test('supports several words in one line, including adjacent ones', () {
      expect(_segments('Ni el {laburo} ni la {guita}{mango}'), <Matcher>[
        _segment('Ni el '),
        _segment('laburo', 'laburo'),
        _segment(' ni la '),
        _segment('guita', 'guita'),
        _segment('mango', 'mango'),
      ]);
    });

    test('a line made only of a word is a single Lunfardo segment', () {
      expect(_segments('{grela}'), <Matcher>[_segment('grela', 'grela')]);
    });

    test('throws FormatException for an unclosed brace', () {
      expect(() => _segments('que es {grela, te deja'), throwsFormatException);
    });

    test('throws FormatException for a stray closing brace', () {
      expect(() => _segments('que es grela}'), throwsFormatException);
    });

    test('throws FormatException for nested braces', () {
      expect(() => _segments('{gre{la}}'), throwsFormatException);
    });

    test('throws FormatException for an empty word', () {
      expect(() => _segments('que es {}'), throwsFormatException);
    });

    test('throws FormatException for a blank surface', () {
      expect(() => _segments('que es { |grela}'), throwsFormatException);
    });

    test('throws FormatException for an empty explicit id', () {
      expect(() => _segments('que es {grela|}'), throwsFormatException);
    });

    test('throws FormatException for more than one separator', () {
      expect(() => _segments('que es {grela|gre|la}'), throwsFormatException);
    });
  });

  group('lineFromMarkup', () {
    test('parses a single line with the same markup rules as text stanzas', () {
      final TextLine line = TextMapper.lineFromMarkup('Ya no {morfo|morfar} con {grela},');

      expect(line.text, 'Ya no morfo con grela,');
      expect(line.segments.map((TextSegment s) => s.wordId).toList(), <String?>[null, 'morfar', null, 'grela', null]);
    });

    test('throws FormatException for a blank line', () {
      expect(() => TextMapper.lineFromMarkup(' '), throwsFormatException);
    });

    test('throws FormatException for malformed markup', () {
      expect(() => TextMapper.lineFromMarkup('que es {grela'), throwsFormatException);
    });
  });
}
