import 'dart:math';

import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockQuoteRepository extends Mock implements QuoteRepository {}

class _FixedRandom implements Random {
  final int value;
  final List<int> requestedMax = <int>[];

  _FixedRandom(this.value);

  @override
  int nextInt(int max) {
    requestedMax.add(max);
    return value;
  }

  @override
  bool nextBool() => throw UnimplementedError();

  @override
  double nextDouble() => throw UnimplementedError();
}

const Quote _first = Quote(line: 'first', title: 'Uno', year: 1917, textId: 'uno');
const Quote _second = Quote(line: 'second', title: 'Dos', year: 1930, textId: 'dos');
const Quote _third = Quote(line: 'third', title: 'Tres', year: 1948, textId: 'tres');

void main() {
  late _MockQuoteRepository repository;

  setUp(() {
    repository = _MockQuoteRepository();
  });

  group('execute', () {
    test('returns the quote at the random index', () async {
      when(() => repository.getQuotes()).thenAnswer((_) async => <Quote>[_first, _second, _third]);
      final _FixedRandom random = _FixedRandom(1);
      final GetRandomQuoteUseCase useCase = GetRandomQuoteUseCase(quoteRepository: repository, random: random);

      final Quote? result = await useCase.execute(const NoParams());

      expect(result, same(_second));
      expect(random.requestedMax, <int>[3]);
      verify(() => repository.getQuotes()).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('returns the only quote when there is exactly one', () async {
      when(() => repository.getQuotes()).thenAnswer((_) async => <Quote>[_third]);
      final GetRandomQuoteUseCase useCase = GetRandomQuoteUseCase(quoteRepository: repository, random: _FixedRandom(0));

      expect(await useCase.execute(const NoParams()), same(_third));
    });

    test('returns null and does not draw a random index when there are no quotes', () async {
      when(() => repository.getQuotes()).thenAnswer((_) async => <Quote>[]);
      final _FixedRandom random = _FixedRandom(0);
      final GetRandomQuoteUseCase useCase = GetRandomQuoteUseCase(quoteRepository: repository, random: random);

      expect(await useCase.execute(const NoParams()), isNull);
      expect(random.requestedMax, isEmpty);
    });

    test('rethrows QuoteLoadException from the repository', () async {
      const QuoteLoadException exception = QuoteLoadException();
      when(() => repository.getQuotes()).thenThrow(exception);
      final GetRandomQuoteUseCase useCase = GetRandomQuoteUseCase(quoteRepository: repository, random: _FixedRandom(0));

      await expectLater(useCase.execute(const NoParams()), throwsA(same(exception)));
    });

    test('rethrows unknown AppException from the repository', () async {
      when(() => repository.getQuotes()).thenThrow(const AppException.unknown());
      final GetRandomQuoteUseCase useCase = GetRandomQuoteUseCase(quoteRepository: repository, random: _FixedRandom(0));

      await expectLater(useCase.execute(const NoParams()), throwsA(isA<AppException>()));
    });
  });
}
