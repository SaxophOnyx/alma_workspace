import 'package:data/data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAssetBundle extends Mock implements AssetBundle {}

const String _patternsKey = 'packages/data/assets/content/breathing_patterns.json';
const String _quotesKey = 'packages/data/assets/content/quotes.json';

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
}
