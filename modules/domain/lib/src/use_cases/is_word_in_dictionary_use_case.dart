import '../repositories/dictionary_repository.dart';
import 'template_use_cases.dart';

class IsWordInDictionaryUseCase implements FutureUseCase<IsWordInDictionaryParams, bool> {
  final DictionaryRepository _dictionaryRepository;

  const IsWordInDictionaryUseCase({
    required DictionaryRepository dictionaryRepository,
  }) : _dictionaryRepository = dictionaryRepository;

  @override
  Future<bool> execute(IsWordInDictionaryParams input) async {
    final List<String> wordIds = await _dictionaryRepository.getWordIds();
    return wordIds.contains(input.wordId);
  }
}

class IsWordInDictionaryParams {
  final String wordId;

  const IsWordInDictionaryParams({
    required this.wordId,
  });
}
