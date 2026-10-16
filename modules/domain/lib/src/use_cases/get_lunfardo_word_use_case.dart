import '../exceptions/lunfardo_word_not_found_exception.dart';
import '../models/lunfardo_word.dart';
import '../repositories/lunfardo_word_repository.dart';
import 'template_use_cases.dart';

class GetLunfardoWordUseCase implements FutureUseCase<GetLunfardoWordParams, LunfardoWord> {
  final LunfardoWordRepository _lunfardoWordRepository;

  const GetLunfardoWordUseCase({
    required LunfardoWordRepository lunfardoWordRepository,
  }) : _lunfardoWordRepository = lunfardoWordRepository;

  @override
  Future<LunfardoWord> execute(GetLunfardoWordParams input) async {
    final List<LunfardoWord> words = await _lunfardoWordRepository.getWords();
    for (final LunfardoWord word in words) {
      if (word.id == input.wordId) return word;
    }

    throw const LunfardoWordNotFoundException();
  }
}

class GetLunfardoWordParams {
  final String wordId;

  const GetLunfardoWordParams({
    required this.wordId,
  });
}
