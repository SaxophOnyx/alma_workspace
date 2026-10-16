import 'package:domain/domain.dart';
import 'package:shared_ui/shared_ui.dart';

final class HablarExceptionMapper {
  const HablarExceptionMapper._();

  static String map(Exception error, AppTranslations t) {
    return switch (error) {
      LunfardoWordLoadException() ||
      LunfardoWordNotFoundException() ||
      WordOfTheDayReadException() ||
      WordOfTheDayWriteException() => t.hablar.errors.wordUnavailable,
      DictionaryReadException() || DictionaryWriteException() => t.hablar.errors.dictionaryUnavailable,
      EncounteredWordsReadException() || EncounteredWordsWriteException() => t.hablar.errors.quizUnavailable,
      _ => t.hablar.errors.unknown,
    };
  }
}
