import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockDictionaryRepository extends Mock implements DictionaryRepository {}

void main() {
  late _MockDictionaryRepository repository;
  late IsWordInDictionaryUseCase useCase;

  setUp(() {
    repository = _MockDictionaryRepository();
    useCase = IsWordInDictionaryUseCase(dictionaryRepository: repository);
  });

  group('execute', () {
    test('returns true when the word is saved', () async {
      when(() => repository.getWordIds()).thenAnswer((_) async => <String>['mina', 'grela']);

      final bool result = await useCase.execute(const IsWordInDictionaryParams(wordId: 'grela'));

      expect(result, isTrue);
      verify(() => repository.getWordIds()).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('returns false when the word is not saved', () async {
      when(() => repository.getWordIds()).thenAnswer((_) async => <String>['mina']);

      expect(await useCase.execute(const IsWordInDictionaryParams(wordId: 'grela')), isFalse);
    });

    test('returns false for an empty dictionary', () async {
      when(() => repository.getWordIds()).thenAnswer((_) async => <String>[]);

      expect(await useCase.execute(const IsWordInDictionaryParams(wordId: 'grela')), isFalse);
    });

    test('never writes to the dictionary', () async {
      when(() => repository.getWordIds()).thenAnswer((_) async => <String>[]);

      await useCase.execute(const IsWordInDictionaryParams(wordId: 'grela'));

      verifyNever(() => repository.addWord(any()));
    });

    test('rethrows DictionaryReadException from the repository', () async {
      const DictionaryReadException exception = DictionaryReadException();
      when(() => repository.getWordIds()).thenThrow(exception);

      await expectLater(useCase.execute(const IsWordInDictionaryParams(wordId: 'grela')), throwsA(same(exception)));
    });

    test('rethrows unknown AppException from the repository', () async {
      when(() => repository.getWordIds()).thenThrow(const AppException.unknown());

      await expectLater(
        useCase.execute(const IsWordInDictionaryParams(wordId: 'grela')),
        throwsA(isA<AppException>()),
      );
    });
  });
}
