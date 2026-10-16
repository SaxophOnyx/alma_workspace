import 'dart:math';

import '../exceptions/lunfardo_word_not_found_exception.dart';
import '../models/lunfardo_word.dart';
import '../models/word_of_the_day_selection.dart';
import '../repositories/lunfardo_word_repository.dart';
import '../repositories/word_of_the_day_repository.dart';
import 'template_use_cases.dart';

/// Returns today's word: one per local calendar day, with no repeats until every word has been shown.
class GetWordOfTheDayUseCase implements FutureUseCase<NoParams, LunfardoWord> {
  final LunfardoWordRepository _lunfardoWordRepository;
  final WordOfTheDayRepository _wordOfTheDayRepository;
  final DateTime Function() _now;
  final Random _random;

  GetWordOfTheDayUseCase({
    required LunfardoWordRepository lunfardoWordRepository,
    required WordOfTheDayRepository wordOfTheDayRepository,
    DateTime Function()? now,
    Random? random,
  }) : _lunfardoWordRepository = lunfardoWordRepository,
       _wordOfTheDayRepository = wordOfTheDayRepository,
       _now = now ?? DateTime.now,
       _random = random ?? Random();

  @override
  Future<LunfardoWord> execute(NoParams input) async {
    final List<LunfardoWord> words = await _lunfardoWordRepository.getWords();
    final WordOfTheDaySelection? selection = await _wordOfTheDayRepository.getSelection();
    if (words.isEmpty) throw const LunfardoWordNotFoundException();

    final DateTime now = _now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final Map<String, LunfardoWord> wordsById = <String, LunfardoWord>{
      for (final LunfardoWord word in words) word.id: word,
    };

    if (selection != null && selection.date == today) {
      if (wordsById[selection.wordId] case final LunfardoWord word) return word;
    }

    // Drop ids that no longer match a word so they cannot hold a cycle open.
    List<String> shownWordIds = <String>[
      for (final String id in selection?.shownWordIds ?? const <String>[])
        if (wordsById.containsKey(id)) id,
    ];
    List<LunfardoWord> candidates = <LunfardoWord>[
      for (final LunfardoWord word in words)
        if (!shownWordIds.contains(word.id)) word,
    ];
    if (candidates.isEmpty) {
      shownWordIds = <String>[];
      candidates = <LunfardoWord>[
        for (final LunfardoWord word in words)
          if (words.length == 1 || word.id != selection?.wordId) word,
      ];
    }

    final LunfardoWord picked = candidates[_random.nextInt(candidates.length)];
    await _wordOfTheDayRepository.saveSelection(
      WordOfTheDaySelection(
        wordId: picked.id,
        date: today,
        shownWordIds: <String>[...shownWordIds, picked.id],
      ),
    );

    return picked;
  }
}
