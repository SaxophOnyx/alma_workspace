import 'package:core/core.dart';
import 'package:domain/domain.dart';

import '../providers/providers.dart';

final class LocalDictionaryRepository implements DictionaryRepository {
  static const String _wordIdsKey = 'personal_dictionary';

  final LocalStorageProvider _localStorageProvider;

  const LocalDictionaryRepository({
    required LocalStorageProvider localStorageProvider,
  }) : _localStorageProvider = localStorageProvider;

  @override
  Future<List<String>> getWordIds() async {
    try {
      return await _readWordIds();
    } on LocalStorageException catch (_) {
      throw const DictionaryReadException();
    } on Exception catch (_) {
      throw const AppException.unknown();
    }
  }

  @override
  Future<void> addWord(String wordId) async {
    try {
      final List<String> wordIds = await _readWordIds();
      await _localStorageProvider.setStringList(_wordIdsKey, <String>[...wordIds, wordId]);
    } on LocalStorageException catch (e) {
      throw switch (e.operation) {
        LocalStorageOperation.read => const DictionaryReadException(),
        LocalStorageOperation.write => const DictionaryWriteException(),
      };
    } on Exception catch (_) {
      throw const AppException.unknown();
    }
  }

  Future<List<String>> _readWordIds() async {
    return await _localStorageProvider.getStringList(_wordIdsKey) ?? <String>[];
  }
}
