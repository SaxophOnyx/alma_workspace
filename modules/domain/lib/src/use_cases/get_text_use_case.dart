import '../exceptions/text_not_found_exception.dart';
import '../models/tango_text.dart';
import '../repositories/text_repository.dart';
import 'template_use_cases.dart';

class GetTextUseCase implements FutureUseCase<GetTextParams, TangoText> {
  final TextRepository _textRepository;

  const GetTextUseCase({
    required TextRepository textRepository,
  }) : _textRepository = textRepository;

  @override
  Future<TangoText> execute(GetTextParams input) async {
    final List<TangoText> texts = await _textRepository.getTexts();
    for (final TangoText text in texts) {
      if (text.id == input.textId) return text;
    }

    throw const TextNotFoundException();
  }
}

class GetTextParams {
  final String textId;

  const GetTextParams({
    required this.textId,
  });
}
