import '../models/breathing_mode.dart';
import '../models/breathing_pattern.dart';

abstract interface class BreathingPatternRepository {
  Future<BreathingPattern> getPattern(BreathingMode mode);
}
