part of 'respirar_duration_bloc.dart';

sealed class RespirarDurationEvent {
  const RespirarDurationEvent();
}

final class DurationSelected extends RespirarDurationEvent {
  final SessionDuration duration;

  const DurationSelected(this.duration);
}

final class DurationBackPressed extends RespirarDurationEvent {
  const DurationBackPressed();
}
