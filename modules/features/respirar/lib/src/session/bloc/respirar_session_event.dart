part of 'respirar_session_bloc.dart';

sealed class RespirarSessionEvent {
  const RespirarSessionEvent();
}

final class SessionStarted extends RespirarSessionEvent {
  const SessionStarted();
}

final class ScreenTapped extends RespirarSessionEvent {
  const ScreenTapped();
}

final class ExitRequested extends RespirarSessionEvent {
  const ExitRequested();
}

final class AppBackgrounded extends RespirarSessionEvent {
  const AppBackgrounded();
}

final class _PhaseCompleted extends RespirarSessionEvent {
  final int timerId;

  const _PhaseCompleted(this.timerId);
}

final class _SessionCompleted extends RespirarSessionEvent {
  final int timerId;

  const _SessionCompleted(this.timerId);
}
