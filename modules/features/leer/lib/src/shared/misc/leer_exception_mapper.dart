import 'package:domain/domain.dart';
import 'package:shared_ui/shared_ui.dart';

final class LeerExceptionMapper {
  const LeerExceptionMapper._();

  static String map(Exception error, AppTranslations t) {
    return switch (error) {
      TextLoadException() || TextNotFoundException() => t.leer.errors.textUnavailable,
      LunfardoWordLoadException() || LunfardoWordNotFoundException() => t.leer.errors.wordUnavailable,
      DictionaryReadException() || DictionaryWriteException() => t.leer.errors.dictionaryUnavailable,
      _ => t.leer.errors.unknown,
    };
  }
}
