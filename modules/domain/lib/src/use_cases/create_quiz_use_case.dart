import 'dart:math';

import '../models/lunfardo_word.dart';
import '../models/quiz_question.dart';
import '../models/quiz_question_type.dart';
import '../repositories/dictionary_repository.dart';
import '../repositories/encountered_words_repository.dart';
import '../repositories/lunfardo_word_repository.dart';
import 'template_use_cases.dart';

/// Builds a quiz about words the user has encountered or saved; empty when there are none.
///
/// Words repeat to fill [questionCount] when fewer were encountered, each time with another question type.
class CreateQuizUseCase implements FutureUseCase<NoParams, List<QuizQuestion>> {
  static const int questionCount = 10;
  static const int _optionCount = 4;

  final LunfardoWordRepository _lunfardoWordRepository;
  final EncounteredWordsRepository _encounteredWordsRepository;
  final DictionaryRepository _dictionaryRepository;
  final Random _random;

  CreateQuizUseCase({
    required LunfardoWordRepository lunfardoWordRepository,
    required EncounteredWordsRepository encounteredWordsRepository,
    required DictionaryRepository dictionaryRepository,
    Random? random,
  }) : _lunfardoWordRepository = lunfardoWordRepository,
       _encounteredWordsRepository = encounteredWordsRepository,
       _dictionaryRepository = dictionaryRepository,
       _random = random ?? Random();

  @override
  Future<List<QuizQuestion>> execute(NoParams input) async {
    final List<LunfardoWord> words = await _lunfardoWordRepository.getWords();
    final List<String> encounteredIds = await _encounteredWordsRepository.getWordIds();
    final List<String> dictionaryIds = await _dictionaryRepository.getWordIds();

    final Set<String> knownIds = <String>{...encounteredIds, ...dictionaryIds};
    final List<LunfardoWord> pool = <LunfardoWord>[
      for (final LunfardoWord word in words)
        if (knownIds.contains(word.id)) word,
    ];
    if (pool.isEmpty) return const <QuizQuestion>[];

    pool.shuffle(_random);
    final Map<String, List<QuizQuestionType>> typesById = <String, List<QuizQuestionType>>{
      for (final LunfardoWord word in pool) word.id: _typesFor(word)..shuffle(_random),
    };

    final List<QuizQuestion> questions = <QuizQuestion>[];
    for (int i = 0; i < questionCount; i++) {
      final LunfardoWord word = pool[i % pool.length];
      final List<QuizQuestionType> types = typesById[word.id]!;
      final int round = i ~/ pool.length;
      questions.add(_buildQuestion(word: word, type: types[round % types.length], words: words));
    }

    return questions;
  }

  List<QuizQuestionType> _typesFor(LunfardoWord word) {
    return <QuizQuestionType>[
      for (final QuizQuestionType type in QuizQuestionType.values)
        if (type != QuizQuestionType.related || word.related.isNotEmpty) type,
    ];
  }

  QuizQuestion _buildQuestion({
    required LunfardoWord word,
    required QuizQuestionType type,
    required List<LunfardoWord> words,
  }) {
    final String relatedClue = type == QuizQuestionType.related
        ? word.related[_random.nextInt(word.related.length)]
        : '';
    final String answer = _optionOf(word, type);

    final List<String> distractors = <String>{
      for (final LunfardoWord other in words)
        if (other.id != word.id && !_isAmbiguous(other, word, type, relatedClue)) _optionOf(other, type),
    }.where((String option) => option != answer).toList()..shuffle(_random);

    final List<String> options = <String>[answer, ...distractors.take(_optionCount - 1)]..shuffle(_random);

    return QuizQuestion(
      type: type,
      word: word,
      options: options,
      correctIndex: options.indexOf(answer),
      relatedClue: relatedClue,
    );
  }

  String _optionOf(LunfardoWord word, QuizQuestionType type) {
    return switch (type) {
      QuizQuestionType.meaning => word.meaning,
      QuizQuestionType.word ||
      QuizQuestionType.etymology ||
      QuizQuestionType.example ||
      QuizQuestionType.related => word.word,
    };
  }

  /// Whether [other] would also be a right answer to the question about [word].
  bool _isAmbiguous(LunfardoWord other, LunfardoWord word, QuizQuestionType type, String relatedClue) {
    return switch (type) {
      QuizQuestionType.meaning || QuizQuestionType.example => false,
      QuizQuestionType.word => other.meaning == word.meaning,
      QuizQuestionType.etymology => other.etymology.first == word.etymology.first,
      QuizQuestionType.related => other.related.contains(relatedClue),
    };
  }
}
