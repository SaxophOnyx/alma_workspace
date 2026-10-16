import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockContentProvider extends Mock implements ContentProvider {}

const List<QuoteEntity> _entities = <QuoteEntity>[
  QuoteEntity(line: 'uno', title: 'Uno', year: 1917, textId: 'uno'),
  QuoteEntity(line: 'dos', title: 'Dos', year: 1930, textId: 'dos'),
];

void main() {
  late _MockContentProvider provider;
  late LocalQuoteRepository repository;

  setUp(() {
    provider = _MockContentProvider();
    repository = LocalQuoteRepository(contentProvider: provider);
  });

  group('getQuotes', () {
    test('returns mapped quotes in content order', () async {
      when(() => provider.loadQuotes()).thenAnswer((_) async => _entities);

      final List<Quote> quotes = await repository.getQuotes();

      expect(quotes.map((Quote q) => q.textId).toList(), <String>['uno', 'dos']);
      expect(quotes.last.year, 1930);
      verify(() => provider.loadQuotes()).called(1);
      verifyNoMoreInteractions(provider);
    });

    test('returns an empty list when content is empty', () async {
      when(() => provider.loadQuotes()).thenAnswer((_) async => <QuoteEntity>[]);

      expect(await repository.getQuotes(), isEmpty);
    });

    test('loads content only once across calls', () async {
      when(() => provider.loadQuotes()).thenAnswer((_) async => _entities);

      await repository.getQuotes();
      clearInteractions(provider);
      final List<Quote> second = await repository.getQuotes();

      expect(second, hasLength(2));
      verifyNever(() => provider.loadQuotes());
    });

    test('maps ContentLoadException to QuoteLoadException', () async {
      when(() => provider.loadQuotes()).thenThrow(const ContentLoadException(ContentType.quotes));

      await expectLater(repository.getQuotes(), throwsA(isA<QuoteLoadException>()));
    });

    test('maps malformed content to QuoteLoadException', () async {
      when(() => provider.loadQuotes()).thenAnswer(
        (_) async => const <QuoteEntity>[QuoteEntity(line: '', title: 'Uno', year: 1917, textId: 'uno')],
      );

      await expectLater(repository.getQuotes(), throwsA(isA<QuoteLoadException>()));
    });

    test('maps an unexpected exception to AppException.unknown', () async {
      when(() => provider.loadQuotes()).thenThrow(Exception('boom'));

      await expectLater(
        repository.getQuotes(),
        throwsA(
          isA<AppException>()
              .having((AppException e) => e.message, 'message', const AppException.unknown().message)
              .having((AppException e) => e, 'type', isNot(isA<QuoteLoadException>())),
        ),
      );
    });
  });
}
