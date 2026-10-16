import 'package:core/core.dart';
import 'package:domain/domain.dart';

import '../providers/providers.dart';

final class LocalWordOfTheDayRepository implements WordOfTheDayRepository {
  static const String _wordIdKey = 'word_of_day_id';
  static const String _dateKey = 'word_of_day_date';
  static const String _shownWordIdsKey = 'word_of_day_shown';

  static final RegExp _datePattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  final LocalStorageProvider _localStorageProvider;

  const LocalWordOfTheDayRepository({
    required LocalStorageProvider localStorageProvider,
  }) : _localStorageProvider = localStorageProvider;

  @override
  Future<WordOfTheDaySelection?> getSelection() async {
    try {
      final String? wordId = await _localStorageProvider.getString(_wordIdKey);
      final String? rawDate = await _localStorageProvider.getString(_dateKey);
      final List<String>? shownWordIds = await _localStorageProvider.getStringList(_shownWordIdsKey);

      final DateTime? date = rawDate == null ? null : _parseDate(rawDate);
      if (wordId == null || date == null) return null;

      return WordOfTheDaySelection(
        wordId: wordId,
        date: date,
        shownWordIds: shownWordIds ?? <String>[wordId],
      );
    } on LocalStorageException catch (_) {
      throw const WordOfTheDayReadException();
    } on Exception catch (_) {
      throw const AppException.unknown();
    }
  }

  @override
  Future<void> saveSelection(WordOfTheDaySelection selection) async {
    try {
      // The word id goes last: a selection only counts once it is fully written.
      await _localStorageProvider.setStringList(_shownWordIdsKey, selection.shownWordIds);
      await _localStorageProvider.setString(_dateKey, _formatDate(selection.date));
      await _localStorageProvider.setString(_wordIdKey, selection.wordId);
    } on LocalStorageException catch (e) {
      throw switch (e.operation) {
        LocalStorageOperation.read => const WordOfTheDayReadException(),
        LocalStorageOperation.write => const WordOfTheDayWriteException(),
      };
    } on Exception catch (_) {
      throw const AppException.unknown();
    }
  }

  /// Parses `yyyy-MM-dd` into local midnight; `null` for anything else, including impossible dates.
  static DateTime? _parseDate(String raw) {
    final RegExpMatch? match = _datePattern.firstMatch(raw);
    if (match == null) return null;

    final int year = int.parse(match.group(1)!);
    final int month = int.parse(match.group(2)!);
    final int day = int.parse(match.group(3)!);
    final DateTime date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) return null;

    return date;
  }

  static String _formatDate(DateTime date) {
    final String year = date.year.toString().padLeft(4, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
