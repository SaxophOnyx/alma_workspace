import 'package:core/core.dart';
import 'package:domain/domain.dart';

import '../entities/entities.dart';
import '../mappers/mappers.dart';
import '../providers/providers.dart';

final class LocalTextRepository implements TextRepository {
  final ContentProvider _contentProvider;

  List<TangoText>? _texts;

  LocalTextRepository({
    required ContentProvider contentProvider,
  }) : _contentProvider = contentProvider;

  @override
  Future<List<TangoText>> getTexts() async {
    return _texts ??= await _loadTexts();
  }

  Future<List<TangoText>> _loadTexts() async {
    try {
      final List<TextEntity> entities = await _contentProvider.loadTexts();
      return entities.map(TextMapper.fromEntity).toList();
    } on ContentLoadException catch (_) {
      throw const TextLoadException();
    } on FormatException catch (_) {
      throw const TextLoadException();
    } on Exception catch (_) {
      throw const AppException.unknown();
    }
  }
}
