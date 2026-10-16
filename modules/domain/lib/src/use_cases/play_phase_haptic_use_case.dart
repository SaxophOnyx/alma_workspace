import '../services/haptic_feedback_service.dart';
import 'template_use_cases.dart';

class PlayPhaseHapticUseCase implements FutureUseCase<NoParams, void> {
  final HapticFeedbackService _hapticFeedbackService;

  const PlayPhaseHapticUseCase({
    required HapticFeedbackService hapticFeedbackService,
  }) : _hapticFeedbackService = hapticFeedbackService;

  @override
  Future<void> execute(NoParams input) async {
    await _hapticFeedbackService.pulse();
  }
}
