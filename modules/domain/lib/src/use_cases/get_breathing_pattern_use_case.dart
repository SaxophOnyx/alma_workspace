import '../models/breathing_mode.dart';
import '../models/breathing_pattern.dart';
import '../repositories/breathing_pattern_repository.dart';
import 'template_use_cases.dart';

class GetBreathingPatternUseCase implements FutureUseCase<GetBreathingPatternParams, BreathingPattern> {
  final BreathingPatternRepository _breathingPatternRepository;

  const GetBreathingPatternUseCase({
    required BreathingPatternRepository breathingPatternRepository,
  }) : _breathingPatternRepository = breathingPatternRepository;

  @override
  Future<BreathingPattern> execute(GetBreathingPatternParams input) async {
    return await _breathingPatternRepository.getPattern(input.mode);
  }
}

class GetBreathingPatternParams {
  final BreathingMode mode;

  const GetBreathingPatternParams({
    required this.mode,
  });
}
