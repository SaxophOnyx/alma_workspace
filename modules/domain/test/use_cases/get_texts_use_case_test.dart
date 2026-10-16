import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockTextRepository extends Mock implements TextRepository {}

TangoText _text(String id, int year) {
  return TangoText(
    id: id,
    title: id,
    author: 'Autor',
    year: year,
    context: 'context',
    stanzas: const <TextStanza>[
      TextStanza(
        lines: <TextLine>[
          TextLine(segments: <TextSegment>[TextSegment(text: 'line')]),
        ],
      ),
    ],
  );
}

void main() {
  late _MockTextRepository repository;
  late GetTextsUseCase useCase;

  setUp(() {
    repository = _MockTextRepository();
    useCase = GetTextsUseCase(textRepository: repository);
  });

  group('execute', () {
    test('returns texts in repository order without sorting by year', () async {
      final List<TangoText> texts = <TangoText>[_text('cambalache', 1934), _text('mi_noche_triste', 1917)];
      when(() => repository.getTexts()).thenAnswer((_) async => texts);

      final List<TangoText> result = await useCase.execute(const NoParams());

      expect(result.map((TangoText t) => t.id).toList(), <String>['cambalache', 'mi_noche_triste']);
      verify(() => repository.getTexts()).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('returns an empty list when there are no texts', () async {
      when(() => repository.getTexts()).thenAnswer((_) async => <TangoText>[]);

      expect(await useCase.execute(const NoParams()), isEmpty);
    });

    test('rethrows TextLoadException from the repository', () async {
      const TextLoadException exception = TextLoadException();
      when(() => repository.getTexts()).thenThrow(exception);

      await expectLater(useCase.execute(const NoParams()), throwsA(same(exception)));
    });

    test('rethrows unknown AppException from the repository', () async {
      when(() => repository.getTexts()).thenThrow(const AppException.unknown());

      await expectLater(useCase.execute(const NoParams()), throwsA(isA<AppException>()));
    });
  });
}
