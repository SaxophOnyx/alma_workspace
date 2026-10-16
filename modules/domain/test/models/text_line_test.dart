import 'package:domain/domain.dart';
import 'package:test/test.dart';

void main() {
  group('TextLine.text', () {
    test('joins every segment in order', () {
      const TextLine line = TextLine(
        segments: <TextSegment>[
          TextSegment(text: 'que es '),
          TextSegment(text: 'grela', wordId: 'grela'),
          TextSegment(text: ','),
        ],
      );

      expect(line.text, 'que es grela,');
    });

    test('is empty when there are no segments', () {
      expect(const TextLine(segments: <TextSegment>[]).text, isEmpty);
    });
  });

  group('TextSegment.isLunfardo', () {
    test('is true when the segment references a word', () {
      expect(const TextSegment(text: 'grela', wordId: 'grela').isLunfardo, isTrue);
    });

    test('is false for plain text', () {
      expect(const TextSegment(text: 'que es ').isLunfardo, isFalse);
    });
  });
}
