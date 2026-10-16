import '../repositories/dictionary_repository.dart';
import 'template_use_cases.dart';

class AddWordToDictionaryUseCase implements FutureUseCase<AddWordToDictionaryParams, void> {
  final DictionaryRepository _dictionaryRepository;

  const AddWordToDictionaryUseCase({
    required DictionaryRepository dictionaryRepository,
  }) : _dictionaryRepository = dictionaryRepository;

  @override
  Future<void> execute(AddWordToDictionaryParams input) async {
    final List<String> wordIds = await _dictionaryRepository.getWordIds();
    if (wordIds.contains(input.wordId)) return;

    await _dictionaryRepository.addWord(input.wordId);
  }
}

class AddWordToDictionaryParams {
  final String wordId;

  const AddWordToDictionaryParams({
    required this.wordId,
  });
}
