import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'local_storage_exception.dart';
import 'local_storage_operation.dart';
import 'local_storage_provider.dart';

final class SharedPreferencesLocalStorageProvider implements LocalStorageProvider {
  final SharedPreferencesAsync _preferences;

  const SharedPreferencesLocalStorageProvider({
    required SharedPreferencesAsync preferences,
  }) : _preferences = preferences;

  @override
  Future<bool?> getBool(String key) async {
    try {
      return await _preferences.getBool(key);
    } on PlatformException catch (_) {
      throw const LocalStorageException(LocalStorageOperation.read);
    } on Exception catch (_) {
      throw const LocalStorageException(LocalStorageOperation.read);
    }
  }

  @override
  Future<void> setBool(String key, {required bool value}) async {
    try {
      await _preferences.setBool(key, value);
    } on PlatformException catch (_) {
      throw const LocalStorageException(LocalStorageOperation.write);
    } on Exception catch (_) {
      throw const LocalStorageException(LocalStorageOperation.write);
    }
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    try {
      return await _preferences.getStringList(key);
    } on PlatformException catch (_) {
      throw const LocalStorageException(LocalStorageOperation.read);
    } on Exception catch (_) {
      throw const LocalStorageException(LocalStorageOperation.read);
    }
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    try {
      await _preferences.setStringList(key, value);
    } on PlatformException catch (_) {
      throw const LocalStorageException(LocalStorageOperation.write);
    } on Exception catch (_) {
      throw const LocalStorageException(LocalStorageOperation.write);
    }
  }
}
