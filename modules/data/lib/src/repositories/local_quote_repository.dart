import 'package:core/core.dart';
import 'package:domain/domain.dart';

import '../entities/entities.dart';
import '../mappers/mappers.dart';
import '../providers/providers.dart';

final class LocalQuoteRepository implements QuoteRepository {
  final ContentProvider _contentProvider;

  List<Quote>? _quotes;

  LocalQuoteRepository({
    required ContentProvider contentProvider,
  }) : _contentProvider = contentProvider;

  @override
  Future<List<Quote>> getQuotes() async {
    return _quotes ??= await _loadQuotes();
  }

  Future<List<Quote>> _loadQuotes() async {
    try {
      final List<QuoteEntity> entities = await _contentProvider.loadQuotes();
      return entities.map(QuoteMapper.fromEntity).toList();
    } on ContentLoadException catch (_) {
      throw const QuoteLoadException();
    } on FormatException catch (_) {
      throw const QuoteLoadException();
    } on Exception catch (_) {
      throw const AppException.unknown();
    }
  }
}
