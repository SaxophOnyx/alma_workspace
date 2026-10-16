abstract interface class DictionaryRepository {
  Future<List<String>> getWordIds();

  Future<void> addWord(String wordId);
}
