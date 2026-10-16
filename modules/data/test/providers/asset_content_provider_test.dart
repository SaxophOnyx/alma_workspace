import 'package:data/data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAssetBundle extends Mock implements AssetBundle {}

const String _patternsKey = 'packages/data/assets/content/breathing_patterns.json';
const String _quotesKey = 'packages/data/assets/content/quotes.json';
const String _textsKey = 'packages/data/assets/content/texts.json';
const String _wordsKey = 'packages/data/assets/content/lunfardo_words.json';

void main() {
  late _MockAssetBundle bundle;
  late AssetContentProvider provider;

  setUp(() {
    bundle = _MockAssetBundle();
    provider = AssetContentProvider(bundle: bundle);
  });

  Matcher contentLoadException(ContentType type) {
    return throwsA(isA<ContentLoadException>().having((ContentLoadException e) => e.type, 'type', type));
  }

  group('loadBreathingPatterns', () {
    test('parses patterns with and without hold progression', () async {
      when(() => bundle.loadString(_patternsKey)).thenAnswer(
        (_) async => '''
[
  {"mode": "compas", "phases": [{"type": "inhale", "durationMs": 6000}]},
  {
    "mode": "pausa",
    "phases": [{"type": "hold", "durationMs": 3000}],
    "holdProgression": {"phaseIndex": 0, "fromMs": 3000, "toMs": 12000, "stepMs": 1000}
  }
]''',
      );

      final List<BreathingPatternEntity> patterns = await provider.loadBreathingPatterns();

      expect(patterns, hasLength(2));
      expect(patterns[0].mode, 'compas');
      expect(patterns[0].phases.single.type, 'inhale');
      expect(patterns[0].phases.single.durationMs, 6000);
      expect(patterns[0].holdProgression, isNull);
      expect(patterns[1].holdProgression!.toMs, 12000);
      verify(() => bundle.loadString(_patternsKey)).called(1);
    });

    test('returns an empty list for an empty array', () async {
      when(() => bundle.loadString(_patternsKey)).thenAnswer((_) async => '[]');

      expect(await provider.loadBreathingPatterns(), isEmpty);
    });

    test('throws ContentLoadException when the asset is missing', () async {
      when(() => bundle.loadString(_patternsKey)).thenThrow(FlutterError('Unable to load asset'));

      await expectLater(provider.loadBreathingPatterns(), contentLoadException(ContentType.breathingPatterns));
    });

    test('throws ContentLoadException for malformed JSON', () async {
      when(() => bundle.loadString(_patternsKey)).thenAnswer((_) async => '[{');

      await expectLater(provider.loadBreathingPatterns(), contentLoadException(ContentType.breathingPatterns));
    });

    test('throws ContentLoadException when the root is not a list', () async {
      when(() => bundle.loadString(_patternsKey)).thenAnswer((_) async => '{"mode": "compas"}');

      await expectLater(provider.loadBreathingPatterns(), contentLoadException(ContentType.breathingPatterns));
    });

    test('throws ContentLoadException when a required field is missing', () async {
      when(() => bundle.loadString(_patternsKey)).thenAnswer((_) async => '[{"phases": []}]');

      await expectLater(provider.loadBreathingPatterns(), contentLoadException(ContentType.breathingPatterns));
    });

    test('throws ContentLoadException when a field has the wrong type', () async {
      when(() => bundle.loadString(_patternsKey)).thenAnswer(
        (_) async => '[{"mode": "compas", "phases": [{"type": "inhale", "durationMs": "6000"}]}]',
      );

      await expectLater(provider.loadBreathingPatterns(), contentLoadException(ContentType.breathingPatterns));
    });

    test('throws ContentLoadException on an unexpected exception', () async {
      when(() => bundle.loadString(_patternsKey)).thenThrow(Exception('boom'));

      await expectLater(provider.loadBreathingPatterns(), contentLoadException(ContentType.breathingPatterns));
    });
  });

  group('loadQuotes', () {
    test('parses quotes', () async {
      when(() => bundle.loadString(_quotesKey)).thenAnswer(
        (_) async => '[{"line": "a\\nb", "title": "Yira, yira", "year": 1930, "textId": "yira_yira"}]',
      );

      final List<QuoteEntity> quotes = await provider.loadQuotes();

      expect(quotes.single.line, 'a\nb');
      expect(quotes.single.title, 'Yira, yira');
      expect(quotes.single.year, 1930);
      expect(quotes.single.textId, 'yira_yira');
    });

    test('returns an empty list for an empty array', () async {
      when(() => bundle.loadString(_quotesKey)).thenAnswer((_) async => '[]');

      expect(await provider.loadQuotes(), isEmpty);
    });

    test('throws ContentLoadException when the asset is missing', () async {
      when(() => bundle.loadString(_quotesKey)).thenThrow(FlutterError('Unable to load asset'));

      await expectLater(provider.loadQuotes(), contentLoadException(ContentType.quotes));
    });

    test('throws ContentLoadException when a required field is null', () async {
      when(() => bundle.loadString(_quotesKey)).thenAnswer(
        (_) async => '[{"line": null, "title": "Yira, yira", "year": 1930, "textId": "yira_yira"}]',
      );

      await expectLater(provider.loadQuotes(), contentLoadException(ContentType.quotes));
    });
  });

  group('loadTexts', () {
    test('parses texts with nested stanzas', () async {
      when(() => bundle.loadString(_textsKey)).thenAnswer(
        (_) async => '''
[
  {
    "id": "yira_yira",
    "title": "Yira, yira",
    "author": "Enrique Santos Discépolo",
    "year": 1930,
    "context": "Argentina after the 1930 coup.",
    "stanzas": [["uno", "que es {grela}"], ["tres"]]
  }
]''',
      );

      final List<TextEntity> texts = await provider.loadTexts();

      expect(texts.single.id, 'yira_yira');
      expect(texts.single.author, 'Enrique Santos Discépolo');
      expect(texts.single.year, 1930);
      expect(texts.single.context, 'Argentina after the 1930 coup.');
      expect(texts.single.stanzas, <List<String>>[
        <String>['uno', 'que es {grela}'],
        <String>['tres'],
      ]);
      verify(() => bundle.loadString(_textsKey)).called(1);
    });

    test('returns an empty list for an empty array', () async {
      when(() => bundle.loadString(_textsKey)).thenAnswer((_) async => '[]');

      expect(await provider.loadTexts(), isEmpty);
    });

    test('throws ContentLoadException when the asset is missing', () async {
      when(() => bundle.loadString(_textsKey)).thenThrow(FlutterError('Unable to load asset'));

      await expectLater(provider.loadTexts(), contentLoadException(ContentType.texts));
    });

    test('throws ContentLoadException when stanzas are not nested lists', () async {
      when(() => bundle.loadString(_textsKey)).thenAnswer(
        (_) async => '[{"id": "a", "title": "A", "author": "B", "year": 1930, "context": "c", "stanzas": ["uno"]}]',
      );

      await expectLater(provider.loadTexts(), contentLoadException(ContentType.texts));
    });

    test('throws ContentLoadException when a required field is missing', () async {
      when(() => bundle.loadString(_textsKey)).thenAnswer(
        (_) async => '[{"id": "a", "title": "A", "year": 1930, "context": "c", "stanzas": []}]',
      );

      await expectLater(provider.loadTexts(), contentLoadException(ContentType.texts));
    });
  });

  group('loadLunfardoWords', () {
    test('parses words', () async {
      when(() => bundle.loadString(_wordsKey)).thenAnswer(
        (_) async => '[{"id": "grela", "word": "grela", "meaning": "fickle fate", "etymology": "Italian grilla"}]',
      );

      final List<LunfardoWordEntity> words = await provider.loadLunfardoWords();

      expect(words.single.id, 'grela');
      expect(words.single.word, 'grela');
      expect(words.single.meaning, 'fickle fate');
      expect(words.single.etymology, 'Italian grilla');
    });

    test('returns an empty list for an empty array', () async {
      when(() => bundle.loadString(_wordsKey)).thenAnswer((_) async => '[]');

      expect(await provider.loadLunfardoWords(), isEmpty);
    });

    test('throws ContentLoadException when the asset is missing', () async {
      when(() => bundle.loadString(_wordsKey)).thenThrow(FlutterError('Unable to load asset'));

      await expectLater(provider.loadLunfardoWords(), contentLoadException(ContentType.lunfardoWords));
    });

    test('throws ContentLoadException when a required field is null', () async {
      when(() => bundle.loadString(_wordsKey)).thenAnswer(
        (_) async => '[{"id": "grela", "word": null, "meaning": "fickle fate", "etymology": "Italian grilla"}]',
      );

      await expectLater(provider.loadLunfardoWords(), contentLoadException(ContentType.lunfardoWords));
    });
  });
}
