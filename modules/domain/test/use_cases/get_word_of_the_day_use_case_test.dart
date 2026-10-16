import 'dart:math';

import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../helpers/word_fixtures.dart';

class _MockLunfardoWordRepository extends Mock implements LunfardoWordRepository {}

class _MockWordOfTheDayRepository extends Mock implements WordOfTheDayRepository {}

class _QueueRandom implements Random {
  final List<int> _values;
  final List<int> requestedMax = <int>[];

  _QueueRandom(List<int> values) : _values = List<int>.of(values);

  @override
  int nextInt(int max) {
    requestedMax.add(max);
    return _values.removeAt(0);
  }

  @override
  bool nextBool() => throw UnimplementedError();

  @override
  double nextDouble() => throw UnimplementedError();
}

class _FakeSelection extends Fake implements WordOfTheDaySelection {}

final LunfardoWord _grela = buildWord('grela');
final LunfardoWord _mina = buildWord('mina');
final LunfardoWord _morfar = buildWord('morfar');

final DateTime _today = DateTime(2026, 10, 16);
final DateTime _yesterday = DateTime(2026, 10, 15);

Matcher _isSelection({required String wordId, required DateTime date, required List<String> shown}) {
  return isA<WordOfTheDaySelection>()
      .having((WordOfTheDaySelection s) => s.wordId, 'wordId', wordId)
      .having((WordOfTheDaySelection s) => s.date, 'date', date)
      .having((WordOfTheDaySelection s) => s.shownWordIds, 'shownWordIds', shown);
}

void main() {
  late _MockLunfardoWordRepository wordRepository;
  late _MockWordOfTheDayRepository selectionRepository;

  setUpAll(() {
    registerFallbackValue(_FakeSelection());
  });

  setUp(() {
    wordRepository = _MockLunfardoWordRepository();
    selectionRepository = _MockWordOfTheDayRepository();
    when(() => wordRepository.getWords()).thenAnswer((_) async => <LunfardoWord>[_grela, _mina, _morfar]);
    when(() => selectionRepository.saveSelection(any())).thenAnswer((_) async {});
  });

  GetWordOfTheDayUseCase buildUseCase({required DateTime now, Random? random}) {
    return GetWordOfTheDayUseCase(
      lunfardoWordRepository: wordRepository,
      wordOfTheDayRepository: selectionRepository,
      now: () => now,
      random: random ?? _QueueRandom(<int>[]),
    );
  }

  group('execute', () {
    test('picks a word on first use and remembers it for today', () async {
      when(() => selectionRepository.getSelection()).thenAnswer((_) async => null);
      final _QueueRandom random = _QueueRandom(<int>[1]);

      final LunfardoWord result = await buildUseCase(
        now: DateTime(2026, 10, 16, 9, 30),
        random: random,
      ).execute(const NoParams());

      expect(result, same(_mina));
      expect(random.requestedMax, <int>[3]);
      verify(
        () => selectionRepository.saveSelection(
          any(that: _isSelection(wordId: 'mina', date: _today, shown: <String>['mina'])),
        ),
      ).called(1);
    });

    test('returns the same word for the rest of the local day', () async {
      when(() => selectionRepository.getSelection()).thenAnswer(
        (_) async => WordOfTheDaySelection(wordId: 'morfar', date: _today, shownWordIds: const <String>['morfar']),
      );

      final LunfardoWord result = await buildUseCase(now: DateTime(2026, 10, 16, 23, 59, 59)).execute(const NoParams());

      expect(result, same(_morfar));
      verifyNever(() => selectionRepository.saveSelection(any()));
    });

    test('picks a new word right after local midnight among words not shown yet', () async {
      when(() => selectionRepository.getSelection()).thenAnswer(
        (_) async =>
            WordOfTheDaySelection(wordId: 'mina', date: _yesterday, shownWordIds: const <String>['grela', 'mina']),
      );
      final _QueueRandom random = _QueueRandom(<int>[0]);

      final LunfardoWord result = await buildUseCase(
        now: DateTime(2026, 10, 16, 0, 0, 1),
        random: random,
      ).execute(const NoParams());

      expect(result, same(_morfar));
      expect(random.requestedMax, <int>[1]);
      verify(
        () => selectionRepository.saveSelection(
          any(that: _isSelection(wordId: 'morfar', date: _today, shown: <String>['grela', 'mina', 'morfar'])),
        ),
      ).called(1);
    });

    test('starts a new cycle once every word has been shown, skipping yesterday\'s word', () async {
      when(() => selectionRepository.getSelection()).thenAnswer(
        (_) async => WordOfTheDaySelection(
          wordId: 'morfar',
          date: _yesterday,
          shownWordIds: const <String>['grela', 'mina', 'morfar'],
        ),
      );
      final _QueueRandom random = _QueueRandom(<int>[1]);

      final LunfardoWord result = await buildUseCase(now: _today, random: random).execute(const NoParams());

      expect(result, same(_mina));
      expect(random.requestedMax, <int>[2]);
      verify(
        () => selectionRepository.saveSelection(
          any(that: _isSelection(wordId: 'mina', date: _today, shown: <String>['mina'])),
        ),
      ).called(1);
    });

    test('repeats the only word when the content has a single word', () async {
      when(() => wordRepository.getWords()).thenAnswer((_) async => <LunfardoWord>[_grela]);
      when(() => selectionRepository.getSelection()).thenAnswer(
        (_) async => WordOfTheDaySelection(wordId: 'grela', date: _yesterday, shownWordIds: const <String>['grela']),
      );

      final LunfardoWord result = await buildUseCase(
        now: _today,
        random: _QueueRandom(<int>[0]),
      ).execute(const NoParams());

      expect(result, same(_grela));
      verify(
        () => selectionRepository.saveSelection(
          any(that: _isSelection(wordId: 'grela', date: _today, shown: <String>['grela'])),
        ),
      ).called(1);
    });

    test('ignores shown ids that no longer match a word', () async {
      when(() => selectionRepository.getSelection()).thenAnswer(
        (_) async => WordOfTheDaySelection(
          wordId: 'gone',
          date: _yesterday,
          shownWordIds: const <String>['gone', 'grela', 'mina'],
        ),
      );

      final LunfardoWord result = await buildUseCase(
        now: _today,
        random: _QueueRandom(<int>[0]),
      ).execute(const NoParams());

      expect(result, same(_morfar));
      verify(
        () => selectionRepository.saveSelection(
          any(that: _isSelection(wordId: 'morfar', date: _today, shown: <String>['grela', 'mina', 'morfar'])),
        ),
      ).called(1);
    });

    test('picks a new word today when the saved word no longer exists', () async {
      when(() => selectionRepository.getSelection()).thenAnswer(
        (_) async => WordOfTheDaySelection(wordId: 'gone', date: _today, shownWordIds: const <String>['gone']),
      );
      final _QueueRandom random = _QueueRandom(<int>[2]);

      final LunfardoWord result = await buildUseCase(now: _today, random: random).execute(const NoParams());

      expect(result, same(_morfar));
      expect(random.requestedMax, <int>[3]);
      verify(
        () => selectionRepository.saveSelection(
          any(that: _isSelection(wordId: 'morfar', date: _today, shown: <String>['morfar'])),
        ),
      ).called(1);
    });

    test('throws LunfardoWordNotFoundException when there are no words', () async {
      when(() => wordRepository.getWords()).thenAnswer((_) async => <LunfardoWord>[]);
      when(() => selectionRepository.getSelection()).thenAnswer((_) async => null);

      await expectLater(
        buildUseCase(now: _today).execute(const NoParams()),
        throwsA(isA<LunfardoWordNotFoundException>()),
      );
      verifyNever(() => selectionRepository.saveSelection(any()));
    });

    test('rethrows LunfardoWordLoadException without touching the selection', () async {
      const LunfardoWordLoadException exception = LunfardoWordLoadException();
      when(() => wordRepository.getWords()).thenThrow(exception);

      await expectLater(buildUseCase(now: _today).execute(const NoParams()), throwsA(same(exception)));
      verifyZeroInteractions(selectionRepository);
    });

    test('rethrows WordOfTheDayReadException', () async {
      const WordOfTheDayReadException exception = WordOfTheDayReadException();
      when(() => selectionRepository.getSelection()).thenThrow(exception);

      await expectLater(buildUseCase(now: _today).execute(const NoParams()), throwsA(same(exception)));
      verifyNever(() => selectionRepository.saveSelection(any()));
    });

    test('rethrows WordOfTheDayWriteException when the pick cannot be saved', () async {
      const WordOfTheDayWriteException exception = WordOfTheDayWriteException();
      when(() => selectionRepository.getSelection()).thenAnswer((_) async => null);
      when(() => selectionRepository.saveSelection(any())).thenThrow(exception);

      await expectLater(
        buildUseCase(now: _today, random: _QueueRandom(<int>[0])).execute(const NoParams()),
        throwsA(same(exception)),
      );
    });

    test('rethrows unknown AppException', () async {
      when(() => selectionRepository.getSelection()).thenThrow(const AppException.unknown());

      await expectLater(buildUseCase(now: _today).execute(const NoParams()), throwsA(isA<AppException>()));
    });
  });
}
