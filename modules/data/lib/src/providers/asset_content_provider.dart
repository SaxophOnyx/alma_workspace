import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../entities/entities.dart';
import 'content_load_exception.dart';
import 'content_provider.dart';
import 'content_type.dart';

final class AssetContentProvider implements ContentProvider {
  static const String _breathingPatternsKey = 'packages/data/assets/content/breathing_patterns.json';
  static const String _quotesKey = 'packages/data/assets/content/quotes.json';

  final AssetBundle _bundle;

  const AssetContentProvider({
    required AssetBundle bundle,
  }) : _bundle = bundle;

  @override
  Future<List<BreathingPatternEntity>> loadBreathingPatterns() {
    return _loadList(_breathingPatternsKey, ContentType.breathingPatterns, BreathingPatternEntity.fromJson);
  }

  @override
  Future<List<QuoteEntity>> loadQuotes() {
    return _loadList(_quotesKey, ContentType.quotes, QuoteEntity.fromJson);
  }

  Future<List<T>> _loadList<T>(
    String key,
    ContentType type,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    try {
      final String raw = await _bundle.loadString(key);
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        throw FormatException('Content root must be a list', key);
      }
      return decoded.map((dynamic item) => fromJson(item as Map<String, dynamic>)).toList();
    } on FlutterError catch (_) {
      throw ContentLoadException(type);
    } on FormatException catch (_) {
      throw ContentLoadException(type);
    } on TypeError catch (_) {
      // Missing or mistyped field in generated fromJson.
      throw ContentLoadException(type);
    } on Exception catch (_) {
      throw ContentLoadException(type);
    }
  }
}
