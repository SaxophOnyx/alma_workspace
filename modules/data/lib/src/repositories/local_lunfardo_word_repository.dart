import 'package:core/core.dart';
import 'package:domain/domain.dart';

import '../entities/entities.dart';
import '../mappers/mappers.dart';
import '../providers/providers.dart';

final class LocalLunfardoWordRepository implements LunfardoWordRepository {
  final ContentProvider _contentProvider;

  List<LunfardoWord>? _words;

  LocalLunfardoWordRepository({
    required ContentProvider contentProvider,
  }) : _contentProvider = contentProvider;

  @override
  Future<List<LunfardoWord>> getWords() async {
    return _words ??= await _loadWords();
  }

  Future<List<LunfardoWord>> _loadWords() async {
    try {
      final List<LunfardoWordEntity> entities = await _contentProvider.loadLunfardoWords();
      return entities.map(LunfardoWordMapper.fromEntity).toList();
    } on ContentLoadException catch (_) {
      throw const LunfardoWordLoadException();
    } on FormatException catch (_) {
      throw const LunfardoWordLoadException();
    } on Exception catch (_) {
      throw const AppException.unknown();
    }
  }
}
