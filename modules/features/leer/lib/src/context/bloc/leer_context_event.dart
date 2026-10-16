part of 'leer_context_bloc.dart';

sealed class LeerContextEvent {
  const LeerContextEvent();
}

final class ContextStarted extends LeerContextEvent {
  const ContextStarted();
}

final class ReadPressed extends LeerContextEvent {
  const ReadPressed();
}

final class ContextBackPressed extends LeerContextEvent {
  const ContextBackPressed();
}
