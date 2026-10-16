import 'package:core/core.dart';
import 'package:domain/domain.dart';

import '../entities/entities.dart';
import '../mappers/mappers.dart';
import '../providers/providers.dart';

final class LocalBreathingPatternRepository implements BreathingPatternRepository {
  final ContentProvider _contentProvider;

  List<BreathingPattern>? _patterns;

  LocalBreathingPatternRepository({
    required ContentProvider contentProvider,
  }) : _contentProvider = contentProvider;

  @override
  Future<BreathingPattern> getPattern(BreathingMode mode) async {
    final List<BreathingPattern> patterns = _patterns ??= await _loadPatterns();

    for (final BreathingPattern pattern in patterns) {
      if (pattern.mode == mode) return pattern;
    }
    throw const BreathingPatternLoadException();
  }

  Future<List<BreathingPattern>> _loadPatterns() async {
    try {
      final List<BreathingPatternEntity> entities = await _contentProvider.loadBreathingPatterns();
      return entities.map(BreathingPatternMapper.fromEntity).toList();
    } on ContentLoadException catch (_) {
      throw const BreathingPatternLoadException();
    } on FormatException catch (_) {
      throw const BreathingPatternLoadException();
    } on Exception catch (_) {
      throw const AppException.unknown();
    }
  }
}
