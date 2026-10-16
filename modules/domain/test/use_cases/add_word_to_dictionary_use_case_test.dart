import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockDictionaryRepository extends Mock implements DictionaryRepository {}

void main() {
  late _MockDictionaryRepository repository;
  late AddWordToDictionaryUseCase useCase;

  setUp(() {
    repository = _MockDictionaryRepository();
    useCase = AddWordToDictionaryUseCase(dictionaryRepository: repository);
    when(() => repository.addWord(any())).thenAnswer((_) async {});
  });

  group('execute', () {
    test('adds a word that is not saved yet', () async {
      when(() => repository.getWordIds()).thenAnswer((_) async => <String>['mina']);

      await useCase.execute(const AddWordToDictionaryParams(wordId: 'grela'));

      verifyInOrder(<void Function()>[
        () => repository.getWordIds(),
        () => repository.addWord('grela'),
      ]);
      verifyNoMoreInteractions(repository);
    });

    test('adds the first word to an empty dictionary', () async {
      when(() => repository.getWordIds()).thenAnswer((_) async => <String>[]);

      await useCase.execute(const AddWordToDictionaryParams(wordId: 'grela'));

      verify(() => repository.addWord('grela')).called(1);
    });

    test('does not add a word that is already saved', () async {
      when(() => repository.getWordIds()).thenAnswer((_) async => <String>['grela']);

      await useCase.execute(const AddWordToDictionaryParams(wordId: 'grela'));

      verifyNever(() => repository.addWord(any()));
    });

    test('rethrows DictionaryReadException without writing', () async {
      const DictionaryReadException exception = DictionaryReadException();
      when(() => repository.getWordIds()).thenThrow(exception);

      await expectLater(useCase.execute(const AddWordToDictionaryParams(wordId: 'grela')), throwsA(same(exception)));
      verifyNever(() => repository.addWord(any()));
    });

    test('rethrows DictionaryWriteException when the read succeeds but the write fails', () async {
      const DictionaryWriteException exception = DictionaryWriteException();
      when(() => repository.getWordIds()).thenAnswer((_) async => <String>[]);
      when(() => repository.addWord('grela')).thenThrow(exception);

      await expectLater(useCase.execute(const AddWordToDictionaryParams(wordId: 'grela')), throwsA(same(exception)));
    });

    test('rethrows unknown AppException from the repository', () async {
      when(() => repository.getWordIds()).thenThrow(const AppException.unknown());

      await expectLater(
        useCase.execute(const AddWordToDictionaryParams(wordId: 'grela')),
        throwsA(isA<AppException>()),
      );
    });
  });
}
