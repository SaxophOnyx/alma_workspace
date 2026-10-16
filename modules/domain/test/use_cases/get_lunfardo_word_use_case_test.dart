import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockLunfardoWordRepository extends Mock implements LunfardoWordRepository {}

const LunfardoWord _grela = LunfardoWord(
  id: 'grela',
  word: 'grela',
  meaning: 'fickle fate',
  etymology: 'Italian grilla',
);
const LunfardoWord _mina = LunfardoWord(id: 'mina', word: 'mina', meaning: 'woman', etymology: 'Italian mina');

void main() {
  late _MockLunfardoWordRepository repository;
  late GetLunfardoWordUseCase useCase;

  setUp(() {
    repository = _MockLunfardoWordRepository();
    useCase = GetLunfardoWordUseCase(lunfardoWordRepository: repository);
  });

  group('execute', () {
    test('returns the word with the requested id', () async {
      when(() => repository.getWords()).thenAnswer((_) async => <LunfardoWord>[_mina, _grela]);

      final LunfardoWord result = await useCase.execute(const GetLunfardoWordParams(wordId: 'grela'));

      expect(result, same(_grela));
      verify(() => repository.getWords()).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('throws LunfardoWordNotFoundException for an unknown id', () async {
      when(() => repository.getWords()).thenAnswer((_) async => <LunfardoWord>[_mina]);

      await expectLater(
        useCase.execute(const GetLunfardoWordParams(wordId: 'grela')),
        throwsA(isA<LunfardoWordNotFoundException>()),
      );
    });

    test('throws LunfardoWordNotFoundException when there are no words', () async {
      when(() => repository.getWords()).thenAnswer((_) async => <LunfardoWord>[]);

      await expectLater(
        useCase.execute(const GetLunfardoWordParams(wordId: 'grela')),
        throwsA(isA<LunfardoWordNotFoundException>()),
      );
    });

    test('rethrows LunfardoWordLoadException from the repository', () async {
      const LunfardoWordLoadException exception = LunfardoWordLoadException();
      when(() => repository.getWords()).thenThrow(exception);

      await expectLater(useCase.execute(const GetLunfardoWordParams(wordId: 'grela')), throwsA(same(exception)));
    });

    test('rethrows unknown AppException from the repository', () async {
      when(() => repository.getWords()).thenThrow(const AppException.unknown());

      await expectLater(
        useCase.execute(const GetLunfardoWordParams(wordId: 'grela')),
        throwsA(isA<AppException>()),
      );
    });
  });
}
