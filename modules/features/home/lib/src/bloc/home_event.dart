part of 'home_bloc.dart';

sealed class HomeEvent {
  const HomeEvent();
}

final class EntryPressed extends HomeEvent {
  final HomeEntry entry;

  const EntryPressed(this.entry);
}
