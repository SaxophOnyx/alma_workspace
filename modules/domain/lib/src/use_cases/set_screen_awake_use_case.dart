import '../services/screen_awake_service.dart';
import 'template_use_cases.dart';

class SetScreenAwakeUseCase implements FutureUseCase<SetScreenAwakeParams, void> {
  final ScreenAwakeService _screenAwakeService;

  const SetScreenAwakeUseCase({
    required ScreenAwakeService screenAwakeService,
  }) : _screenAwakeService = screenAwakeService;

  @override
  Future<void> execute(SetScreenAwakeParams input) async {
    await _screenAwakeService.setEnabled(enabled: input.enabled);
  }
}

class SetScreenAwakeParams {
  final bool enabled;

  const SetScreenAwakeParams({
    required this.enabled,
  });
}
