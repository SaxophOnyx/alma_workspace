import '../models/word_of_the_day_selection.dart';

abstract interface class WordOfTheDayRepository {
  Future<WordOfTheDaySelection?> getSelection();

  Future<void> saveSelection(WordOfTheDaySelection selection);
}
