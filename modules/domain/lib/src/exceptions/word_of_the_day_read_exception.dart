import 'package:core/core.dart';

class WordOfTheDayReadException extends AppException {
  const WordOfTheDayReadException() : super('word_of_the_day_read_failed');
}
