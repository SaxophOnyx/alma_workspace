import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockTextRepository extends Mock implements TextRepository {}

TangoText _text(String id) {
  return TangoText(
    id: id,
    title: id,
    author: 'Autor',
    year: 1930,
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
  late GetTextUseCase useCase;

  setUp(() {
    repository = _MockTextRepository();
    useCase = GetTextUseCase(textRepository: repository);
  });

  group('execute', () {
    test('returns the text with the requested id', () async {
      final TangoText yira = _text('yira_yira');
      when(() => repository.getTexts()).thenAnswer((_) async => <TangoText>[_text('sur'), yira]);

      final TangoText result = await useCase.execute(const GetTextParams(textId: 'yira_yira'));

      expect(result, same(yira));
      verify(() => repository.getTexts()).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('throws TextNotFoundException for an unknown id', () async {
      when(() => repository.getTexts()).thenAnswer((_) async => <TangoText>[_text('sur')]);

      await expectLater(
        useCase.execute(const GetTextParams(textId: 'yira_yira')),
        throwsA(isA<TextNotFoundException>()),
      );
    });

    test('throws TextNotFoundException when there are no texts', () async {
      when(() => repository.getTexts()).thenAnswer((_) async => <TangoText>[]);

      await expectLater(
        useCase.execute(const GetTextParams(textId: 'yira_yira')),
        throwsA(isA<TextNotFoundException>()),
      );
    });

    test('throws TextNotFoundException for an empty id', () async {
      when(() => repository.getTexts()).thenAnswer((_) async => <TangoText>[_text('sur')]);

      await expectLater(
        useCase.execute(const GetTextParams(textId: '')),
        throwsA(isA<TextNotFoundException>()),
      );
    });

    test('rethrows TextLoadException from the repository', () async {
      const TextLoadException exception = TextLoadException();
      when(() => repository.getTexts()).thenThrow(exception);

      await expectLater(useCase.execute(const GetTextParams(textId: 'sur')), throwsA(same(exception)));
    });

    test('rethrows unknown AppException from the repository', () async {
      when(() => repository.getTexts()).thenThrow(const AppException.unknown());

      await expectLater(useCase.execute(const GetTextParams(textId: 'sur')), throwsA(isA<AppException>()));
    });
  });
}
