import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:vibration/vibration.dart';

final class PlatformHapticFeedbackService implements HapticFeedbackService {
  static const int _androidPulseDurationMs = 30;
  static const int _androidPulseAmplitude = 80;

  const PlatformHapticFeedbackService();

  @override
  Future<void> pulse() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await Haptics.vibrate(HapticsType.soft);
      } else {
        // The plugin hardcodes USAGE_ALARM, so the pulse follows the alarm vibration setting.
        await Vibration.vibrate(duration: _androidPulseDurationMs, amplitude: _androidPulseAmplitude);
      }
    } on Exception catch (_) {
      // A device without a vibrator must not break the session.
    }
  }
}
