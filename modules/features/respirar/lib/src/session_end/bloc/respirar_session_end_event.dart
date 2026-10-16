part of 'respirar_session_end_bloc.dart';

sealed class RespirarSessionEndEvent {
  const RespirarSessionEndEvent();
}

final class SessionEndStarted extends RespirarSessionEndEvent {
  const SessionEndStarted();
}

/// The quote line or "Read the full text" was tapped.
final class QuotePressed extends RespirarSessionEndEvent {
  const QuotePressed();
}

final class HomePressed extends RespirarSessionEndEvent {
  const HomePressed();
}

final class SessionEndBackPressed extends RespirarSessionEndEvent {
  const SessionEndBackPressed();
}
