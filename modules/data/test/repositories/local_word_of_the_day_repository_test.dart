import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLocalStorageProvider extends Mock implements LocalStorageProvider {}

const String _idKey = 'word_of_day_id';
const String _dateKey = 'word_of_day_date';
const String _shownKey = 'word_of_day_shown';

void main() {
  late _MockLocalStorageProvider provider;
  late LocalWordOfTheDayRepository repository;

  setUp(() {
    provider = _MockLocalStorageProvider();
    repository = LocalWordOfTheDayRepository(localStorageProvider: provider);
  });

  void stubStored({String? id, String? date, List<String>? shown}) {
    when(() => provider.getString(_idKey)).thenAnswer((_) async => id);
    when(() => provider.getString(_dateKey)).thenAnswer((_) async => date);
    when(() => provider.getStringList(_shownKey)).thenAnswer((_) async => shown);
  }

  group('getSelection', () {
    test('returns the stored selection with the date at local midnight', () async {
      stubStored(id: 'grela', date: '2026-10-16', shown: <String>['mina', 'grela']);

      final WordOfTheDaySelection? selection = await repository.getSelection();

      expect(selection, isNotNull);
      expect(selection!.wordId, 'grela');
      expect(selection.date, DateTime(2026, 10, 16));
      expect(selection.date.isUtc, isFalse);
      expect(selection.shownWordIds, <String>['mina', 'grela']);
    });

    test('returns null when nothing was ever saved', () async {
      stubStored();

      expect(await repository.getSelection(), isNull);
    });

    test('returns null when the date is missing', () async {
      stubStored(id: 'grela', shown: <String>['grela']);

      expect(await repository.getSelection(), isNull);
    });

    test('returns null when the word id is missing', () async {
      stubStored(date: '2026-10-16', shown: <String>['grela']);

      expect(await repository.getSelection(), isNull);
    });

    for (final String malformed in <String>['16.10.2026', '2026-13-01', '2026-02-30', '', '2026-10-16T08:00']) {
      test('returns null for a malformed date "$malformed"', () async {
        stubStored(id: 'grela', date: malformed, shown: <String>['grela']);

        expect(await repository.getSelection(), isNull);
      });
    }

    test('falls back to the current word when the shown list is missing', () async {
      stubStored(id: 'grela', date: '2026-01-05');

      final WordOfTheDaySelection? selection = await repository.getSelection();

      expect(selection!.date, DateTime(2026, 1, 5));
      expect(selection.shownWordIds, <String>['grela']);
    });

    test('maps a read LocalStorageException to WordOfTheDayReadException', () async {
      when(() => provider.getString(_idKey)).thenThrow(const LocalStorageException(LocalStorageOperation.read));

      await expectLater(repository.getSelection(), throwsA(isA<WordOfTheDayReadException>()));
    });

    test('maps an unexpected exception to AppException.unknown', () async {
      when(() => provider.getString(_idKey)).thenThrow(Exception('boom'));

      await expectLater(
        repository.getSelection(),
        throwsA(
          isA<AppException>()
              .having((AppException e) => e.message, 'message', const AppException.unknown().message)
              .having((AppException e) => e, 'type', isNot(isA<WordOfTheDayReadException>())),
        ),
      );
    });
  });

  group('saveSelection', () {
    setUp(() {
      when(() => provider.setString(any(), any())).thenAnswer((_) async {});
      when(() => provider.setStringList(any(), any())).thenAnswer((_) async {});
    });

    test('writes the shown list, the zero-padded date and the word id', () async {
      await repository.saveSelection(
        WordOfTheDaySelection(wordId: 'grela', date: DateTime(2026, 3, 7), shownWordIds: const <String>['mina', 'grela']),
      );

      verifyInOrder(<void Function()>[
        () => provider.setStringList(_shownKey, <String>['mina', 'grela']),
        () => provider.setString(_dateKey, '2026-03-07'),
        () => provider.setString(_idKey, 'grela'),
      ]);
      verifyNoMoreInteractions(provider);
    });

    test('stores only the calendar day of the date', () async {
      await repository.saveSelection(
        WordOfTheDaySelection(wordId: 'grela', date: DateTime(2026, 12, 31, 23, 59), shownWordIds: const <String>['grela']),
      );

      verify(() => provider.setString(_dateKey, '2026-12-31')).called(1);
    });

    test('maps a write LocalStorageException to WordOfTheDayWriteException', () async {
      when(() => provider.setStringList(_shownKey, <String>['grela']))
          .thenThrow(const LocalStorageException(LocalStorageOperation.write));

      await expectLater(
        repository.saveSelection(
          WordOfTheDaySelection(wordId: 'grela', date: DateTime(2026, 10, 16), shownWordIds: const <String>['grela']),
        ),
        throwsA(isA<WordOfTheDayWriteException>()),
      );
      verifyNever(() => provider.setString(any(), any()));
    });

    test('maps an unexpected exception to AppException.unknown', () async {
      when(() => provider.setString(_idKey, 'grela')).thenThrow(Exception('boom'));

      await expectLater(
        repository.saveSelection(
          WordOfTheDaySelection(wordId: 'grela', date: DateTime(2026, 10, 16), shownWordIds: const <String>['grela']),
        ),
        throwsA(
          isA<AppException>()
              .having((AppException e) => e.message, 'message', const AppException.unknown().message)
              .having((AppException e) => e, 'type', isNot(isA<WordOfTheDayWriteException>())),
        ),
      );
    });
  });
}
