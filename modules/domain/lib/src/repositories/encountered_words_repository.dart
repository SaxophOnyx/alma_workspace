abstract interface class EncounteredWordsRepository {
  Future<List<String>> getWordIds();

  Future<void> addWord(String wordId);
}
