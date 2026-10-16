abstract interface class HablarNavigator {
  /// Completes once the user returns from the word card.
  Future<void> openWordOfTheDay();

  /// Completes once the user returns from the word card.
  Future<void> openWordCard(String wordId);

  /// Completes once the user returns from the dictionary.
  Future<void> openDictionary();

  /// Completes once the user returns from the quiz.
  Future<void> openQuiz();

  Future<void> openText(String textId);

  /// Returns to the Hablar main screen.
  Future<void> openHablar();

  Future<void> back();
}
