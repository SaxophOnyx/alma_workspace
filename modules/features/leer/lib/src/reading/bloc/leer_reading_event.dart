part of 'leer_reading_bloc.dart';

sealed class LeerReadingEvent {
  const LeerReadingEvent();
}

final class ReadingStarted extends LeerReadingEvent {
  const ReadingStarted();
}

final class ScreenTapped extends LeerReadingEvent {
  const ScreenTapped();
}

final class WordPressed extends LeerReadingEvent {
  final String wordId;

  const WordPressed(this.wordId);
}

final class AnotherTextPressed extends LeerReadingEvent {
  const AnotherTextPressed();
}

final class BreathePressed extends LeerReadingEvent {
  const BreathePressed();
}

final class HomePressed extends LeerReadingEvent {
  const HomePressed();
}

/// System back while the text is ending; reading itself pops normally.
final class TextEndBackPressed extends LeerReadingEvent {
  const TextEndBackPressed();
}

final class _StanzaPauseCompleted extends LeerReadingEvent {
  const _StanzaPauseCompleted();
}

final class _EndSilenceCompleted extends LeerReadingEvent {
  const _EndSilenceCompleted();
}
