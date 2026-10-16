abstract interface class LocalStorageProvider {
  Future<bool?> getBool(String key);

  Future<void> setBool(String key, {required bool value});
}
