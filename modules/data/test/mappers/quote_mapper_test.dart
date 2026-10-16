import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('fromEntity', () {
    test('maps every field', () {
      final Quote quote = QuoteMapper.fromEntity(
        const QuoteEntity(line: 'Y si un día la suerte,\nque es grela...', title: 'Yira, yira', year: 1930, textId: 'yira_yira'),
      );

      expect(quote.line, 'Y si un día la suerte,\nque es grela...');
      expect(quote.title, 'Yira, yira');
      expect(quote.year, 1930);
      expect(quote.textId, 'yira_yira');
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
