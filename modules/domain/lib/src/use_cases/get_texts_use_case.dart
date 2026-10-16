import '../models/tango_text.dart';
import '../repositories/text_repository.dart';
import 'template_use_cases.dart';

class GetTextsUseCase implements FutureUseCase<NoParams, List<TangoText>> {
  final TextRepository _textRepository;

  const GetTextsUseCase({
    required TextRepository textRepository,
  }) : _textRepository = textRepository;

  @override
  Future<List<TangoText>> execute(NoParams input) async {
    return await _textRepository.getTexts();
  }
}
