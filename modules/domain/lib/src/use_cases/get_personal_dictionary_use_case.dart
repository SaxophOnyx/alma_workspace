import '../models/lunfardo_word.dart';
import '../models/personal_dictionary.dart';
import '../repositories/dictionary_repository.dart';
import '../repositories/lunfardo_word_repository.dart';
import 'template_use_cases.dart';

class GetPersonalDictionaryUseCase implements FutureUseCase<NoParams, PersonalDictionary> {
  final DictionaryRepository _dictionaryRepository;
  final LunfardoWordRepository _lunfardoWordRepository;

  const GetPersonalDictionaryUseCase({
    required DictionaryRepository dictionaryRepository,
    required LunfardoWordRepository lunfardoWordRepository,
  }) : _dictionaryRepository = dictionaryRepository,
       _lunfardoWordRepository = lunfardoWordRepository;

  @override
  Future<PersonalDictionary> execute(NoParams input) async {
    final List<String> wordIds = await _dictionaryRepository.getWordIds();
    final List<LunfardoWord> allWords = await _lunfardoWordRepository.getWords();
    final Map<String, LunfardoWord> wordsById = <String, LunfardoWord>{
      for (final LunfardoWord word in allWords) word.id: word,
    };

    return PersonalDictionary(
      words: <LunfardoWord>[
        for (final String id in wordIds)
          if (wordsById[id] case final LunfardoWord word) word,
      ],
      totalWordCount: allWords.length,
    );
  }
}
