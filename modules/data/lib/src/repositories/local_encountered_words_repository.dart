import 'package:core/core.dart';
import 'package:domain/domain.dart';

import '../providers/providers.dart';

final class LocalEncounteredWordsRepository implements EncounteredWordsRepository {
  static const String _wordIdsKey = 'encountered_words';

  final LocalStorageProvider _localStorageProvider;

  const LocalEncounteredWordsRepository({
    required LocalStorageProvider localStorageProvider,
  }) : _localStorageProvider = localStorageProvider;

  @override
  Future<List<String>> getWordIds() async {
    try {
      return await _readWordIds();
    } on LocalStorageException catch (_) {
      throw const EncounteredWordsReadException();
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
        LocalStorageOperation.read => const EncounteredWordsReadException(),
        LocalStorageOperation.write => const EncounteredWordsWriteException(),
      };
    } on Exception catch (_) {
      throw const AppException.unknown();
    }
  }

  Future<List<String>> _readWordIds() async {
    return await _localStorageProvider.getStringList(_wordIdsKey) ?? <String>[];
  }
}
