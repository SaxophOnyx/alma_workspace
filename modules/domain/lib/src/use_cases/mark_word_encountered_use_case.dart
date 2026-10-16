import '../repositories/encountered_words_repository.dart';
import 'template_use_cases.dart';

class MarkWordEncounteredUseCase implements FutureUseCase<MarkWordEncounteredParams, void> {
  final EncounteredWordsRepository _encounteredWordsRepository;

  const MarkWordEncounteredUseCase({
    required EncounteredWordsRepository encounteredWordsRepository,
  }) : _encounteredWordsRepository = encounteredWordsRepository;

  @override
  Future<void> execute(MarkWordEncounteredParams input) async {
    final List<String> wordIds = await _encounteredWordsRepository.getWordIds();
    if (wordIds.contains(input.wordId)) return;

    await _encounteredWordsRepository.addWord(input.wordId);
  }
}

class MarkWordEncounteredParams {
  final String wordId;

  const MarkWordEncounteredParams({
    required this.wordId,
  });
}
