part of 'hablar_main_bloc.dart';

sealed class HablarMainEvent {
  const HablarMainEvent();
}

final class HablarStarted extends HablarMainEvent {
  const HablarStarted();
}

final class EntryPressed extends HablarMainEvent {
  final HablarEntry entry;

  const EntryPressed(this.entry);
}

final class HablarBackPressed extends HablarMainEvent {
  const HablarBackPressed();
}
