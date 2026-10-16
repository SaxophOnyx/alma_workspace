part of 'leer_text_list_bloc.dart';

sealed class LeerTextListEvent {
  const LeerTextListEvent();
}

final class TextListStarted extends LeerTextListEvent {
  const TextListStarted();
}

final class TextPressed extends LeerTextListEvent {
  final String textId;

  const TextPressed(this.textId);
}

final class TextListBackPressed extends LeerTextListEvent {
  const TextListBackPressed();
}
