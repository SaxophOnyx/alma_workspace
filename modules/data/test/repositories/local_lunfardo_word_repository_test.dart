import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockContentProvider extends Mock implements ContentProvider {}

LunfardoWordEntity _entity(String id, {String? meaning}) {
  return LunfardoWordEntity(
    id: id,
    word: id,
    pronunciation: '/$id/',
    meaning: meaning ?? 'meaning of $id',
    etymology: <String>['origin of $id'],
    example: WordExampleEntity(line: 'y la {$id} se fue', title: 'Yira, yira', year: 1930, textId: 'yira_yira'),
    related: const <String>[],
  );
}

final List<LunfardoWordEntity> _entities = <LunfardoWordEntity>[
  _entity('grela', meaning: 'fickle fate'),
  _entity('mina', meaning: 'woman'),
];

void main() {
  late _MockContentProvider provider;
  late LocalLunfardoWordRepository repository;

  setUp(() {
    provider = _MockContentProvider();
    repository = LocalLunfardoWordRepository(contentProvider: provider);
  });

  group('getWords', () {
    test('returns mapped words in content order', () async {
      when(() => provider.loadLunfardoWords()).thenAnswer((_) async => _entities);

      final List<LunfardoWord> words = await repository.getWords();

      expect(words.map((LunfardoWord w) => w.id).toList(), <String>['grela', 'mina']);
      expect(words.first.meaning, 'fickle fate');
      verify(() => provider.loadLunfardoWords()).called(1);
      verifyNoMoreInteractions(provider);
    });

    test('returns an empty list when content is empty', () async {
      when(() => provider.loadLunfardoWords()).thenAnswer((_) async => <LunfardoWordEntity>[]);

      expect(await repository.getWords(), isEmpty);
    });

    test('loads content only once across calls', () async {
      when(() => provider.loadLunfardoWords()).thenAnswer((_) async => _entities);

      await repository.getWords();
      clearInteractions(provider);
      await repository.getWords();

      verifyNever(() => provider.loadLunfardoWords());
    });

    test('maps ContentLoadException to LunfardoWordLoadException', () async {
      when(() => provider.loadLunfardoWords()).thenThrow(const ContentLoadException(ContentType.lunfardoWords));

      await expectLater(repository.getWords(), throwsA(isA<LunfardoWordLoadException>()));
    });

    test('maps malformed content to LunfardoWordLoadException', () async {
      when(() => provider.loadLunfardoWords()).thenAnswer(
        (_) async => <LunfardoWordEntity>[_entity('')],
      );

      await expectLater(repository.getWords(), throwsA(isA<LunfardoWordLoadException>()));
    });

    test('maps an unexpected exception to AppException.unknown', () async {
      when(() => provider.loadLunfardoWords()).thenThrow(Exception('boom'));

      await expectLater(
        repository.getWords(),
        throwsA(
          isA<AppException>()
              .having((AppException e) => e.message, 'message', const AppException.unknown().message)
              .having((AppException e) => e, 'type', isNot(isA<LunfardoWordLoadException>())),
        ),
      );
    });
  });
}
