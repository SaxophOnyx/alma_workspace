import 'package:data/data.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

class _MockSharedPreferencesAsync extends Mock implements SharedPreferencesAsync {}

const String _key = 'some_flag';
const String _listKey = 'some_list';

void main() {
  group('with in-memory storage', () {
    late SharedPreferencesLocalStorageProvider provider;

    setUp(() {
      SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
      provider = SharedPreferencesLocalStorageProvider(preferences: SharedPreferencesAsync());
    });

    test('getBool returns null for a key that was never written', () async {
      expect(await provider.getBool(_key), isNull);
    });

    test('setBool then getBool round-trips true', () async {
      await provider.setBool(_key, value: true);

      expect(await provider.getBool(_key), isTrue);
    });

    test('setBool overwrites a previous value', () async {
      await provider.setBool(_key, value: true);
      await provider.setBool(_key, value: false);

      expect(await provider.getBool(_key), isFalse);
    });

    test('keys are independent', () async {
      await provider.setBool(_key, value: true);

      expect(await provider.getBool('other_flag'), isNull);
    });
  });

  group('error mapping', () {
    late _MockSharedPreferencesAsync preferences;
    late SharedPreferencesLocalStorageProvider provider;

    setUp(() {
      preferences = _MockSharedPreferencesAsync();
      provider = SharedPreferencesLocalStorageProvider(preferences: preferences);
    });

    test('getBool maps PlatformException to a read LocalStorageException', () async {
      when(() => preferences.getBool(_key)).thenThrow(PlatformException(code: 'error'));

      await expectLater(
        provider.getBool(_key),
        throwsA(isA<LocalStorageException>().having(
          (LocalStorageException e) => e.operation,
          'operation',
          LocalStorageOperation.read,
        )),
      );
    });

    test('getBool maps an unexpected exception to a read LocalStorageException', () async {
      when(() => preferences.getBool(_key)).thenThrow(Exception('boom'));

      await expectLater(
        provider.getBool(_key),
        throwsA(isA<LocalStorageException>().having(
          (LocalStorageException e) => e.operation,
          'operation',
          LocalStorageOperation.read,
        )),
      );
    });

    test('setBool maps PlatformException to a write LocalStorageException', () async {
      when(() => preferences.setBool(_key, true)).thenThrow(PlatformException(code: 'error'));

      await expectLater(
        provider.setBool(_key, value: true),
        throwsA(isA<LocalStorageException>().having(
          (LocalStorageException e) => e.operation,
          'operation',
          LocalStorageOperation.write,
        )),
      );
    });

    test('setBool passes the exact key and value to storage', () async {
      when(() => preferences.setBool(_key, false)).thenAnswer((_) async {});

      await provider.setBool(_key, value: false);

      verify(() => preferences.setBool(_key, false)).called(1);
      verifyNoMoreInteractions(preferences);
    });
  });

  group('string lists with in-memory storage', () {
    late SharedPreferencesLocalStorageProvider provider;

    setUp(() {
      SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
      provider = SharedPreferencesLocalStorageProvider(preferences: SharedPreferencesAsync());
    });

    test('getStringList returns null for a key that was never written', () async {
      expect(await provider.getStringList(_listKey), isNull);
    });

    test('setStringList then getStringList round-trips the values in order', () async {
      await provider.setStringList(_listKey, <String>['mina', 'grela']);

      expect(await provider.getStringList(_listKey), <String>['mina', 'grela']);
    });

    test('setStringList overwrites a previous value', () async {
      await provider.setStringList(_listKey, <String>['mina']);
      await provider.setStringList(_listKey, <String>[]);

      expect(await provider.getStringList(_listKey), isEmpty);
    });
  });

  group('string list error mapping', () {
    late _MockSharedPreferencesAsync preferences;
    late SharedPreferencesLocalStorageProvider provider;

    setUp(() {
      preferences = _MockSharedPreferencesAsync();
      provider = SharedPreferencesLocalStorageProvider(preferences: preferences);
    });

    test('getStringList maps PlatformException to a read LocalStorageException', () async {
      when(() => preferences.getStringList(_listKey)).thenThrow(PlatformException(code: 'error'));

      await expectLater(
        provider.getStringList(_listKey),
        throwsA(isA<LocalStorageException>().having(
          (LocalStorageException e) => e.operation,
          'operation',
          LocalStorageOperation.read,
        )),
      );
    });

    test('setStringList maps an unexpected exception to a write LocalStorageException', () async {
      when(() => preferences.setStringList(_listKey, <String>['grela'])).thenThrow(Exception('boom'));

      await expectLater(
        provider.setStringList(_listKey, <String>['grela']),
        throwsA(isA<LocalStorageException>().having(
          (LocalStorageException e) => e.operation,
          'operation',
          LocalStorageOperation.write,
        )),
      );
    });

    test('setStringList passes the exact key and values to storage', () async {
      when(() => preferences.setStringList(_listKey, <String>['grela'])).thenAnswer((_) async {});

      await provider.setStringList(_listKey, <String>['grela']);

      verify(() => preferences.setStringList(_listKey, <String>['grela'])).called(1);
      verifyNoMoreInteractions(preferences);
    });
  });
}
