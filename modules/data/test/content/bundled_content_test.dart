import 'dart:io';

import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Serves `packages/data/<path>` from this package's own files.
class _PackageFileBundle extends CachingAssetBundle {
  static const String _prefix = 'packages/data/';

  @override
  Future<ByteData> load(String key) async {
    final List<int> bytes = await File(key.substring(_prefix.length)).readAsBytes();
    return ByteData.sublistView(Uint8List.fromList(bytes));
  }
}

void main() {
  final AssetContentProvider provider = AssetContentProvider(bundle: _PackageFileBundle());

  test('bundled breathing patterns cover every mode and map cleanly', () async {
    final LocalBreathingPatternRepository repository = LocalBreathingPatternRepository(contentProvider: provider);

    for (final BreathingMode mode in BreathingMode.values) {
      final BreathingPattern pattern = await repository.getPattern(mode);
      expect(pattern.mode, mode);
      expect(pattern.phases, isNotEmpty);
    }
  });

  test('bundled Pausa hold grows from 3s to 12s', () async {
    final BreathingPattern pausa = await LocalBreathingPatternRepository(contentProvider: provider)
        .getPattern(BreathingMode.pausa);
    final int holdIndex = pausa.holdProgression!.phaseIndex;

    expect(pausa.phases[holdIndex].type, BreathingPhaseType.hold);
    expect(pausa.durationOf(phaseIndex: holdIndex, cycle: 0), const Duration(seconds: 3));
    expect(pausa.durationOf(phaseIndex: holdIndex, cycle: 20), const Duration(seconds: 12));
  });

  test('bundled quotes are non-empty and map cleanly', () async {
    final List<Quote> quotes = await LocalQuoteRepository(contentProvider: provider).getQuotes();

    expect(quotes, isNotEmpty);
  });

  test('bundled texts map cleanly and have unique ids', () async {
    final List<TangoText> texts = await LocalTextRepository(contentProvider: provider).getTexts();

    expect(texts, isNotEmpty);
    expect(texts.map((TangoText t) => t.id).toSet(), hasLength(texts.length));
  });

  test('bundled Lunfardo words map cleanly and have unique ids', () async {
    final List<LunfardoWord> words = await LocalLunfardoWordRepository(contentProvider: provider).getWords();

    expect(words, isNotEmpty);
    expect(words.map((LunfardoWord w) => w.id).toSet(), hasLength(words.length));
  });

  test('every word annotated in a text exists in the Lunfardo words', () async {
    final List<TangoText> texts = await LocalTextRepository(contentProvider: provider).getTexts();
    final Set<String> wordIds = (await LocalLunfardoWordRepository(contentProvider: provider).getWords())
        .map((LunfardoWord w) => w.id)
        .toSet();

    final Set<String> annotated = <String>{
      for (final TangoText text in texts)
        for (final TextStanza stanza in text.stanzas)
          for (final TextLine line in stanza.lines)
            for (final TextSegment segment in line.segments)
              if (segment.wordId case final String wordId) wordId,
    };

    expect(annotated, isNotEmpty);
    expect(annotated.difference(wordIds), isEmpty);
  });

  test('every quote links to a bundled text', () async {
    final List<Quote> quotes = await LocalQuoteRepository(contentProvider: provider).getQuotes();
    final Set<String> textIds = (await LocalTextRepository(contentProvider: provider).getTexts())
        .map((TangoText t) => t.id)
        .toSet();

    expect(quotes.map((Quote q) => q.textId).toSet().difference(textIds), isEmpty);
  });
}
