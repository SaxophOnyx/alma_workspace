import '../models/tango_text.dart';

abstract interface class TextRepository {
  Future<List<TangoText>> getTexts();
}
