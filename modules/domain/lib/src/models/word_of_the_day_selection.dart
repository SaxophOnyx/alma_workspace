class WordOfTheDaySelection {
  final String wordId;

  /// Local calendar day the word was picked for; the time part is always midnight.
  final DateTime date;

  /// Words shown in the current cycle, including [wordId].
  final List<String> shownWordIds;

  const WordOfTheDaySelection({
    required this.wordId,
    required this.date,
    required this.shownWordIds,
  });
}
