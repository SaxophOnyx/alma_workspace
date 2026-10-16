import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLocalStorageProvider extends Mock implements LocalStorageProvider {}

const String _key = 'personal_dictionary';

void main() {
  late _MockLocalStorageProvider provider;
  late LocalDictionaryRepository repository;

  setUp(() {
    provider = _MockLocalStorageProvider();
    repository = LocalDictionaryRepository(localStorageProvider: provider);
  });

  group('getWordIds', () {
    test('returns an empty list when nothing was ever saved', () async {
      when(() => provider.getStringList(_key)).thenAnswer((_) async => null);

      expect(await repository.getWordIds(), isEmpty);
      verify(() => provider.getStringList(_key)).called(1);
      verifyNoMoreInteractions(provider);
    });

    test('returns the stored ids in insertion order', () async {
      when(() => provider.getStringList(_key)).thenAnswer((_) async => <String>['mina', 'grela']);

      expect(await repository.getWordIds(), <String>['mina', 'grela']);
    });

    test('maps a read LocalStorageException to DictionaryReadException', () async {
      when(() => provider.getStringList(_key)).thenThrow(const LocalStorageException(LocalStorageOperation.read));

      await expectLater(repository.getWordIds(), throwsA(isA<DictionaryReadException>()));
    });

    test('maps an unexpected exception to AppException.unknown', () async {
      when(() => provider.getStringList(_key)).thenThrow(Exception('boom'));

      await expectLater(
        repository.getWordIds(),
        throwsA(
          isA<AppException>()
              .having((AppException e) => e.message, 'message', const AppException.unknown().message)
              .having((AppException e) => e, 'type', isNot(isA<DictionaryReadException>())),
        ),
      );
    });
  });

  group('addWord', () {
    test('appends the id to the stored list', () async {
      when(() => provider.getStringList(_key)).thenAnswer((_) async => <String>['mina']);
      when(() => provider.setStringList(_key, any())).thenAnswer((_) async {});

      await repository.addWord('grela');

      verifyInOrder(<void Function()>[
        () => provider.getStringList(_key),
        () => provider.setStringList(_key, <String>['mina', 'grela']),
      ]);
      verifyNoMoreInteractions(provider);
    });

    test('creates the list when nothing was saved yet', () async {
      when(() => provider.getStringList(_key)).thenAnswer((_) async => null);
      when(() => provider.setStringList(_key, any())).thenAnswer((_) async {});

      await repository.addWord('grela');

      verify(() => provider.setStringList(_key, <String>['grela'])).called(1);
    });

    test('maps a failed read to DictionaryReadException without writing', () async {
      when(() => provider.getStringList(_key)).thenThrow(const LocalStorageException(LocalStorageOperation.read));

      await expectLater(repository.addWord('grela'), throwsA(isA<DictionaryReadException>()));
      verifyNever(() => provider.setStringList(any(), any()));
    });

    test('maps a failed write to DictionaryWriteException', () async {
      when(() => provider.getStringList(_key)).thenAnswer((_) async => <String>[]);
      when(() => provider.setStringList(_key, <String>['grela']))
          .thenThrow(const LocalStorageException(LocalStorageOperation.write));

      await expectLater(repository.addWord('grela'), throwsA(isA<DictionaryWriteException>()));
    });

    test('maps an unexpected exception to AppException.unknown', () async {
      when(() => provider.getStringList(_key)).thenAnswer((_) async => <String>[]);
      when(() => provider.setStringList(_key, <String>['grela'])).thenThrow(Exception('boom'));

      await expectLater(
        repository.addWord('grela'),
        throwsA(
          isA<AppException>()
              .having((AppException e) => e.message, 'message', const AppException.unknown().message)
              .having((AppException e) => e, 'type', isNot(isA<DictionaryWriteException>())),
        ),
      );
    });
  });
}
