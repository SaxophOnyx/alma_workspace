import '../models/lunfardo_word.dart';

abstract interface class LunfardoWordRepository {
  Future<List<LunfardoWord>> getWords();
}
