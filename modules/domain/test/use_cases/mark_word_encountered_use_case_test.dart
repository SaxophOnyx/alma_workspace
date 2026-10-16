import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockEncounteredWordsRepository extends Mock implements EncounteredWordsRepository {}

void main() {
  late _MockEncounteredWordsRepository repository;
  late MarkWordEncounteredUseCase useCase;

  setUp(() {
    repository = _MockEncounteredWordsRepository();
    useCase = MarkWordEncounteredUseCase(encounteredWordsRepository: repository);
    when(() => repository.addWord(any())).thenAnswer((_) async {});
  });

  group('execute', () {
    test('records a word that has not been encountered yet', () async {
      when(() => repository.getWordIds()).thenAnswer((_) async => <String>['mina']);

      await useCase.execute(const MarkWordEncounteredParams(wordId: 'grela'));

      verifyInOrder(<void Function()>[
        () => repository.getWordIds(),
        () => repository.addWord('grela'),
      ]);
      verifyNoMoreInteractions(repository);
    });

    test('records the first encountered word', () async {
      when(() => repository.getWordIds()).thenAnswer((_) async => <String>[]);

      await useCase.execute(const MarkWordEncounteredParams(wordId: 'grela'));

      verify(() => repository.addWord('grela')).called(1);
    });

    test('does not record a word twice', () async {
      when(() => repository.getWordIds()).thenAnswer((_) async => <String>['grela']);

      await useCase.execute(const MarkWordEncounteredParams(wordId: 'grela'));

      verifyNever(() => repository.addWord(any()));
    });

    test('rethrows EncounteredWordsReadException without writing', () async {
      const EncounteredWordsReadException exception = EncounteredWordsReadException();
      when(() => repository.getWordIds()).thenThrow(exception);

      await expectLater(useCase.execute(const MarkWordEncounteredParams(wordId: 'grela')), throwsA(same(exception)));
      verifyNever(() => repository.addWord(any()));
    });

    test('rethrows EncounteredWordsWriteException when the read succeeds but the write fails', () async {
      const EncounteredWordsWriteException exception = EncounteredWordsWriteException();
      when(() => repository.getWordIds()).thenAnswer((_) async => <String>[]);
      when(() => repository.addWord('grela')).thenThrow(exception);

      await expectLater(useCase.execute(const MarkWordEncounteredParams(wordId: 'grela')), throwsA(same(exception)));
    });

    test('rethrows unknown AppException from the repository', () async {
      when(() => repository.getWordIds()).thenThrow(const AppException.unknown());

      await expectLater(
        useCase.execute(const MarkWordEncounteredParams(wordId: 'grela')),
        throwsA(isA<AppException>()),
      );
    });
  });
}
