import 'package:core/core.dart';

class QuoteLoadException extends AppException {
  const QuoteLoadException() : super('quote_load_failed');
}
