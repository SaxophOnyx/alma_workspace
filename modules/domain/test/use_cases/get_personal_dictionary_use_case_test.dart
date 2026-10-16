import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../helpers/word_fixtures.dart';

class _MockDictionaryRepository extends Mock implements DictionaryRepository {}

class _MockLunfardoWordRepository extends Mock implements LunfardoWordRepository {}

final LunfardoWord _grela = buildWord('grela');
final LunfardoWord _mina = buildWord('mina');
final LunfardoWord _morfar = buildWord('morfar');

void main() {
  late _MockDictionaryRepository dictionaryRepository;
  late _MockLunfardoWordRepository wordRepository;
  late GetPersonalDictionaryUseCase useCase;

  setUp(() {
    dictionaryRepository = _MockDictionaryRepository();
    wordRepository = _MockLunfardoWordRepository();
    useCase = GetPersonalDictionaryUseCase(
      dictionaryRepository: dictionaryRepository,
      lunfardoWordRepository: wordRepository,
    );
    when(() => wordRepository.getWords()).thenAnswer((_) async => <LunfardoWord>[_grela, _mina, _morfar]);
  });

  group('execute', () {
    test('returns saved words in the order they were added', () async {
      when(() => dictionaryRepository.getWordIds()).thenAnswer((_) async => <String>['morfar', 'grela']);

      final PersonalDictionary result = await useCase.execute(const NoParams());

      expect(result.words, <LunfardoWord>[_morfar, _grela]);
      expect(result.totalWordCount, 3);
      expect(result.isComplete, isFalse);
    });

    test('returns an empty dictionary when nothing is saved', () async {
      when(() => dictionaryRepository.getWordIds()).thenAnswer((_) async => <String>[]);

      final PersonalDictionary result = await useCase.execute(const NoParams());

      expect(result.words, isEmpty);
      expect(result.totalWordCount, 3);
      expect(result.isComplete, isFalse);
    });

    test('skips saved ids that no longer match a word', () async {
      when(() => dictionaryRepository.getWordIds()).thenAnswer((_) async => <String>['grela', 'gone', 'mina']);

      final PersonalDictionary result = await useCase.execute(const NoParams());

      expect(result.words, <LunfardoWord>[_grela, _mina]);
    });

    test('is complete when every word is saved', () async {
      when(() => dictionaryRepository.getWordIds()).thenAnswer((_) async => <String>['mina', 'grela', 'morfar']);

      final PersonalDictionary result = await useCase.execute(const NoParams());

      expect(result.words, hasLength(3));
      expect(result.isComplete, isTrue);
    });

    test('is not complete when there are no words at all', () async {
      when(() => wordRepository.getWords()).thenAnswer((_) async => <LunfardoWord>[]);
      when(() => dictionaryRepository.getWordIds()).thenAnswer((_) async => <String>[]);

      final PersonalDictionary result = await useCase.execute(const NoParams());

      expect(result.totalWordCount, 0);
      expect(result.isComplete, isFalse);
    });

    test('rethrows DictionaryReadException', () async {
      const DictionaryReadException exception = DictionaryReadException();
      when(() => dictionaryRepository.getWordIds()).thenThrow(exception);

      await expectLater(useCase.execute(const NoParams()), throwsA(same(exception)));
    });

    test('rethrows LunfardoWordLoadException when the dictionary reads but words fail to load', () async {
      const LunfardoWordLoadException exception = LunfardoWordLoadException();
      when(() => dictionaryRepository.getWordIds()).thenAnswer((_) async => <String>['grela']);
      when(() => wordRepository.getWords()).thenThrow(exception);

      await expectLater(useCase.execute(const NoParams()), throwsA(same(exception)));
    });

    test('rethrows unknown AppException', () async {
      when(() => dictionaryRepository.getWordIds()).thenThrow(const AppException.unknown());

      await expectLater(useCase.execute(const NoParams()), throwsA(isA<AppException>()));
    });
  });
}
