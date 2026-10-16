part of 'respirar_modes_bloc.dart';

sealed class RespirarModesEvent {
  const RespirarModesEvent();
}

final class ModeSelected extends RespirarModesEvent {
  final BreathingMode mode;

  const ModeSelected(this.mode);
}

final class ModesBackPressed extends RespirarModesEvent {
  const ModesBackPressed();
}
