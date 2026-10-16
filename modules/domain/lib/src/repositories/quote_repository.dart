import '../models/quote.dart';

abstract interface class QuoteRepository {
  Future<List<Quote>> getQuotes();
}
