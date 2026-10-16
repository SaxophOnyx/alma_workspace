import 'dart:math';

import '../models/quote.dart';
import '../repositories/quote_repository.dart';
import 'template_use_cases.dart';

/// Returns a random quote, or `null` when no quotes are available.
class GetRandomQuoteUseCase implements FutureUseCase<NoParams, Quote?> {
  final QuoteRepository _quoteRepository;
  final Random _random;

  GetRandomQuoteUseCase({
    required QuoteRepository quoteRepository,
    Random? random,
  }) : _quoteRepository = quoteRepository,
       _random = random ?? Random();

  @override
  Future<Quote?> execute(NoParams input) async {
    final List<Quote> quotes = await _quoteRepository.getQuotes();
    if (quotes.isEmpty) return null;

    return quotes[_random.nextInt(quotes.length)];
  }
}
