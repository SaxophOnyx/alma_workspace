import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockContentProvider extends Mock implements ContentProvider {}

TextEntity _entity(String id, {String title = 'Title'}) {
  return TextEntity(
    id: id,
    title: title,
    author: 'Autor',
    year: 1930,
    context: 'context',
    stanzas: const <List<String>>[
      <String>['que es {grela}'],
    ],
  );
}

void main() {
  late _MockContentProvider provider;
  late LocalTextRepository repository;

  setUp(() {
    provider = _MockContentProvider();
    repository = LocalTextRepository(contentProvider: provider);
  });

  group('getTexts', () {
    test('returns mapped texts in content order', () async {
      when(() => provider.loadTexts()).thenAnswer((_) async => <TextEntity>[_entity('sur'), _entity('yira_yira')]);

      final List<TangoText> texts = await repository.getTexts();

      expect(texts.map((TangoText t) => t.id).toList(), <String>['sur', 'yira_yira']);
      expect(texts.first.stanzas.single.lines.single.segments.last.wordId, 'grela');
      verify(() => provider.loadTexts()).called(1);
      verifyNoMoreInteractions(provider);
    });

    test('returns an empty list when content is empty', () async {
      when(() => provider.loadTexts()).thenAnswer((_) async => <TextEntity>[]);

      expect(await repository.getTexts(), isEmpty);
    });

    test('loads content only once across calls', () async {
      when(() => provider.loadTexts()).thenAnswer((_) async => <TextEntity>[_entity('sur')]);

      await repository.getTexts();
      clearInteractions(provider);
      final List<TangoText> second = await repository.getTexts();

      expect(second, hasLength(1));
      verifyNever(() => provider.loadTexts());
    });

    test('maps ContentLoadException to TextLoadException', () async {
      when(() => provider.loadTexts()).thenThrow(const ContentLoadException(ContentType.texts));

      await expectLater(repository.getTexts(), throwsA(isA<TextLoadException>()));
    });

    test('maps malformed content to TextLoadException', () async {
      when(() => provider.loadTexts()).thenAnswer((_) async => <TextEntity>[_entity('sur', title: '')]);

      await expectLater(repository.getTexts(), throwsA(isA<TextLoadException>()));
    });

    test('retries loading after a failure', () async {
      when(() => provider.loadTexts()).thenThrow(const ContentLoadException(ContentType.texts));
      await expectLater(repository.getTexts(), throwsA(isA<TextLoadException>()));

      when(() => provider.loadTexts()).thenAnswer((_) async => <TextEntity>[_entity('sur')]);

      expect(await repository.getTexts(), hasLength(1));
    });

    test('maps an unexpected exception to AppException.unknown', () async {
      when(() => provider.loadTexts()).thenThrow(Exception('boom'));

      await expectLater(
        repository.getTexts(),
        throwsA(
          isA<AppException>()
              .having((AppException e) => e.message, 'message', const AppException.unknown().message)
              .having((AppException e) => e, 'type', isNot(isA<TextLoadException>())),
        ),
      );
    });
  });
}
