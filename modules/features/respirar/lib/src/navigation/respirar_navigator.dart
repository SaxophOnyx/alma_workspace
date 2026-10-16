import 'package:domain/domain.dart';

abstract interface class RespirarNavigator {
  Future<void> openDurationSelection(BreathingMode mode);

  Future<void> startSession(BreathingMode mode, SessionDuration duration);

  /// Resolves to `true` to leave, `false` to stay, `null` when dismissed.
  Future<bool?> confirmLeaveSession();

  Future<void> resolveLeaveConfirmation({required bool leave});

  Future<void> leaveSession();

  Future<void> openSessionEnd();

  Future<void> openText(String textId);

  Future<void> openHome();

  /// Leaves the Respirar flow, returning to wherever it was entered from.
  Future<void> close();

  Future<void> back();
}
