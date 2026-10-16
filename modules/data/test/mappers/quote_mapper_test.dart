import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('fromEntity', () {
    test('maps every field', () {
      final Quote quote = QuoteMapper.fromEntity(
        const QuoteEntity(line: 'Y si un día la suerte,\nque es grela...', title: 'Yira, yira', year: 1930, textId: 'yira_yira'),
      );

      expect(quote.line.text, 'Y si un día la suerte,\nque es grela...');
      expect(quote.title, 'Yira, yira');
      expect(quote.year, 1930);
      expect(quote.textId, 'yira_yira');
    });

    test('marks Lunfardo words in the line', () {
      final Quote quote = QuoteMapper.fromEntity(
        const QuoteEntity(line: 'que es {grela}...', title: 'Yira, yira', year: 1930, textId: 'yira_yira'),
      );

      expect(quote.line.text, 'que es grela...');
      expect(
        quote.line.segments.where((TextSegment s) => s.isLunfardo).map((TextSegment s) => s.wordId),
        <String>['grela'],
      );
    });

    test('throws FormatException for an empty line', () {
      expect(
        () => QuoteMapper.fromEntity(const QuoteEntity(line: '', title: 'Yira, yira', year: 1930, textId: 'yira_yira')),
        throwsFormatException,
      );
    });

    test('throws FormatException for a whitespace-only line', () {
      expect(
        () => QuoteMapper.fromEntity(const QuoteEntity(line: '  \n ', title: 'Yira, yira', year: 1930, textId: 'yira_yira')),
        throwsFormatException,
      );
    });

    test('throws FormatException for an empty text id', () {
      expect(
        () => QuoteMapper.fromEntity(const QuoteEntity(line: 'line', title: 'Yira, yira', year: 1930, textId: '')),
        throwsFormatException,
      );
    });
  });
}
