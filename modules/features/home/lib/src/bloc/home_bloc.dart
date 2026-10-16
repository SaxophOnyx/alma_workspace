import 'package:shared_ui/shared_ui.dart';

import '../misc/home_entry.dart';
import '../navigation/home_navigator.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeNavigator _navigator;
  final Duration _highlightDuration;

  HomeBloc({
    required HomeNavigator navigator,
    Duration highlightDuration = AppMotions.durationHighlight,
  }) : _navigator = navigator,
       _highlightDuration = highlightDuration,
       super(const HomeState()) {
    on<EntryPressed>(_onEntryPressed);
  }

  Future<void> _onEntryPressed(EntryPressed event, Emitter<HomeState> emit) async {
    if (state.isNavigating) return;
    emit(state.copyWith(isNavigating: true, highlightedEntry: event.entry));

    // The gold highlight stays visible for its full duration before the transition.
    await Future<void>.delayed(_highlightDuration);
    if (isClosed) return;

    try {
      await switch (event.entry) {
        HomeEntry.respirar => _navigator.openRespirar(),
        HomeEntry.hablar => _navigator.openHablar(),
        HomeEntry.leer => _navigator.openLeer(),
      };
    } on Exception catch (_) {
      // Stay usable; the user can tap again.
    }
    if (isClosed) return;

    emit(state.copyWith(isNavigating: false, highlightedEntry: null));
  }
}
