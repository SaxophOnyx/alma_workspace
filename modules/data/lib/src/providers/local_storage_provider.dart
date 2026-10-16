abstract interface class LocalStorageProvider {
  Future<bool?> getBool(String key);

  Future<void> setBool(String key, {required bool value});

  Future<String?> getString(String key);

  Future<void> setString(String key, String value);

  Future<List<String>?> getStringList(String key);

  Future<void> setStringList(String key, List<String> value);
}
