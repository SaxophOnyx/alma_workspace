import '../entities/entities.dart';

abstract interface class ContentProvider {
  Future<List<BreathingPatternEntity>> loadBreathingPatterns();

  Future<List<QuoteEntity>> loadQuotes();
}
