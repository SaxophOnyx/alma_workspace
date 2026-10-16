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
}
