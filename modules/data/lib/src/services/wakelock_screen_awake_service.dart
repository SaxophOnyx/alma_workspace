import 'package:domain/domain.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

final class WakelockScreenAwakeService implements ScreenAwakeService {
  const WakelockScreenAwakeService();

  @override
  Future<void> setEnabled({required bool enabled}) async {
    try {
      await WakelockPlus.toggle(enable: enabled);
    } on Exception catch (_) {
      // Failing to keep the screen on must not break the session.
    }
  }
}
