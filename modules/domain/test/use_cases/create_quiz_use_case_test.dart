import 'dart:math';

import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../helpers/word_fixtures.dart';

class _MockLunfardoWordRepository extends Mock implements LunfardoWordRepository {}

class _MockEncounteredWordsRepository extends Mock implements EncounteredWordsRepository {}

class _MockDictionaryRepository extends Mock implements DictionaryRepository {}

final List<LunfardoWord> _words = <LunfardoWord>[
  buildWord('grela', related: <String>['suerte', 'yeta']),
  buildWord('yeta', related: <String>['suerte']),
  buildWord('mina'),
  buildWord('morfar'),
  buildWord('laburo'),
  buildWord('guita'),
  buildWord('mango'),
  buildWord('chamuyo'),
  buildWord('fané'),
  buildWord('mufa'),
  buildWord('bacán'),
  buildWord('pibe'),
];

String _expectedAnswer(QuizQuestion question) {
  return switch (question.type) {
    QuizQuestionType.meaning => question.word.meaning,
    _ => question.word.word,
  };
}

void main() {
  late _MockLunfardoWordRepository wordRepository;
  late _MockEncounteredWordsRepository encounteredRepository;
  late _MockDictionaryRepository dictionaryRepository;

  setUp(() {
    wordRepository = _MockLunfardoWordRepository();
    encounteredRepository = _MockEncounteredWordsRepository();
    dictionaryRepository = _MockDictionaryRepository();
    when(() => wordRepository.getWords()).thenAnswer((_) async => _words);
    when(() => encounteredRepository.getWordIds()).thenAnswer((_) async => <String>[]);
    when(() => dictionaryRepository.getWordIds()).thenAnswer((_) async => <String>[]);
  });

  CreateQuizUseCase buildUseCase({int seed = 7}) {
    return CreateQuizUseCase(
      lunfardoWordRepository: wordRepository,
      encounteredWordsRepository: encounteredRepository,
      dictionaryRepository: dictionaryRepository,
      random: Random(seed),
    );
  }

  group('execute', () {
    test('returns no questions when no word has been encountered', () async {
      final List<QuizQuestion> result = await buildUseCase().execute(const NoParams());

      expect(result, isEmpty);
    });

    test('returns no questions when encountered ids match no word', () async {
      when(() => encounteredRepository.getWordIds()).thenAnswer((_) async => <String>['gone']);

      final List<QuizQuestion> result = await buildUseCase().execute(const NoParams());

      expect(result, isEmpty);
    });

    test('asks ten questions about distinct words when enough words were encountered', () async {
      final List<String> allIds = _words.map((LunfardoWord w) => w.id).toList();
      when(() => encounteredRepository.getWordIds()).thenAnswer((_) async => allIds);

      final List<QuizQuestion> result = await buildUseCase().execute(const NoParams());

      expect(result, hasLength(CreateQuizUseCase.questionCount));
      expect(CreateQuizUseCase.questionCount, 10);
      expect(result.map((QuizQuestion q) => q.word.id).toSet(), hasLength(10));
    });

    test('draws only from encountered and dictionary words', () async {
      when(() => encounteredRepository.getWordIds()).thenAnswer((_) async => <String>['grela', 'gone']);
      when(() => dictionaryRepository.getWordIds()).thenAnswer((_) async => <String>['mina', 'grela']);

      final List<QuizQuestion> result = await buildUseCase().execute(const NoParams());

      expect(result, hasLength(10));
      expect(result.map((QuizQuestion q) => q.word.id).toSet(), <String>{'grela', 'mina'});
    });

    test('fills ten questions from few words, varying the question type per word', () async {
      when(() => encounteredRepository.getWordIds()).thenAnswer((_) async => <String>['grela', 'mina', 'morfar']);

      final List<QuizQuestion> result = await buildUseCase().execute(const NoParams());

      expect(result, hasLength(10));
      for (final String id in <String>['grela', 'mina', 'morfar']) {
        final List<QuizQuestionType> types = <QuizQuestionType>[
          for (final QuizQuestion q in result)
            if (q.word.id == id) q.type,
        ];
        expect(types, isNotEmpty, reason: id);
        expect(types.toSet(), hasLength(types.length), reason: id);
      }
      for (int i = 1; i < result.length; i++) {
        expect(result[i].word.id, isNot(result[i - 1].word.id));
      }
    });

    test('uses all five question types for a single word with related words', () async {
      when(() => encounteredRepository.getWordIds()).thenAnswer((_) async => <String>['grela']);

      final List<QuizQuestion> result = await buildUseCase().execute(const NoParams());

      expect(result, hasLength(10));
      expect(result.map((QuizQuestion q) => q.type).toSet(), QuizQuestionType.values.toSet());
    });

    test('never asks a related question about a word without related words', () async {
      when(() => encounteredRepository.getWordIds()).thenAnswer((_) async => <String>['mina']);

      final List<QuizQuestion> result = await buildUseCase().execute(const NoParams());

      expect(result, hasLength(10));
      expect(result.map((QuizQuestion q) => q.type), isNot(contains(QuizQuestionType.related)));
    });

    for (int seed = 0; seed < 20; seed++) {
      test('builds four distinct options with the answer at correctIndex (seed $seed)', () async {
        when(
          () => encounteredRepository.getWordIds(),
        ).thenAnswer((_) async => <String>['grela', 'yeta', 'mina', 'morfar']);

        final List<QuizQuestion> result = await buildUseCase(seed: seed).execute(const NoParams());

        for (final QuizQuestion question in result) {
          expect(question.options, hasLength(4));
          expect(question.options.toSet(), hasLength(4));
          expect(question.options[question.correctIndex], _expectedAnswer(question));
          expect(question.isCorrect(question.correctIndex), isTrue);

          if (question.type == QuizQuestionType.related) {
            expect(question.word.related, contains(question.relatedClue));
            for (final String option in question.options) {
              if (option == question.word.word) continue;
              final LunfardoWord distractor = _words.firstWhere((LunfardoWord w) => w.word == option);
              expect(distractor.related, isNot(contains(question.relatedClue)));
            }
          } else {
            expect(question.relatedClue, isEmpty);
          }
        }
      });
    }

    test('builds fewer options when there are not enough other words', () async {
      when(() => wordRepository.getWords()).thenAnswer((_) async => <LunfardoWord>[_words[2], _words[3]]);
      when(() => encounteredRepository.getWordIds()).thenAnswer((_) async => <String>['mina']);

      final List<QuizQuestion> result = await buildUseCase().execute(const NoParams());

      for (final QuizQuestion question in result) {
        expect(question.options, hasLength(2));
        expect(question.options[question.correctIndex], _expectedAnswer(question));
      }
    });

    test('rethrows LunfardoWordLoadException', () async {
      const LunfardoWordLoadException exception = LunfardoWordLoadException();
      when(() => wordRepository.getWords()).thenThrow(exception);

      await expectLater(buildUseCase().execute(const NoParams()), throwsA(same(exception)));
    });

    test('rethrows EncounteredWordsReadException when words load but encounters fail', () async {
      const EncounteredWordsReadException exception = EncounteredWordsReadException();
      when(() => encounteredRepository.getWordIds()).thenThrow(exception);

      await expectLater(buildUseCase().execute(const NoParams()), throwsA(same(exception)));
    });

    test('rethrows DictionaryReadException when encounters load but the dictionary fails', () async {
      const DictionaryReadException exception = DictionaryReadException();
      when(() => encounteredRepository.getWordIds()).thenAnswer((_) async => <String>['grela']);
      when(() => dictionaryRepository.getWordIds()).thenThrow(exception);

      await expectLater(buildUseCase().execute(const NoParams()), throwsA(same(exception)));
    });

    test('rethrows unknown AppException', () async {
      when(() => dictionaryRepository.getWordIds()).thenThrow(const AppException.unknown());

      await expectLater(buildUseCase().execute(const NoParams()), throwsA(isA<AppException>()));
    });
  });
}
