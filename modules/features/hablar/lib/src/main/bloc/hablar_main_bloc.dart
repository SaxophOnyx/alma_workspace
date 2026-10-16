import 'package:domain/domain.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../navigation/hablar_navigator.dart';
import '../misc/hablar_entry.dart';

part 'hablar_main_event.dart';
part 'hablar_main_state.dart';

class HablarMainBloc extends Bloc<HablarMainEvent, HablarMainState> {
  final GetPersonalDictionaryUseCase _getPersonalDictionaryUseCase;
  final HablarNavigator _navigator;

  HablarMainBloc({
    required GetPersonalDictionaryUseCase getPersonalDictionaryUseCase,
    required HablarNavigator navigator,
  }) : _getPersonalDictionaryUseCase = getPersonalDictionaryUseCase,
       _navigator = navigator,
       super(const HablarMainState()) {
    on<HablarStarted>(_onStarted);
    on<EntryPressed>(_onEntryPressed);
    on<HablarBackPressed>(_onBackPressed);
  }

  Future<void> _onStarted(HablarStarted event, Emitter<HablarMainState> emit) async {
    await _loadDictionaryCount(emit);
  }

  Future<void> _onEntryPressed(EntryPressed event, Emitter<HablarMainState> emit) async {
    if (state.isNavigating) return;
    emit(state.copyWith(isNavigating: true));

    try {
      await switch (event.entry) {
        HablarEntry.wordOfTheDay => _navigator.openWordOfTheDay(),
        HablarEntry.dictionary => _navigator.openDictionary(),
        HablarEntry.quiz => _navigator.openQuiz(),
      };
    } on Exception catch (_) {
      // Stay usable; the user can tap again.
    }
    if (isClosed) return;

    emit(state.copyWith(isNavigating: false));
    // The counter may have changed on the screen the user is coming back from.
    await _loadDictionaryCount(emit);
  }

  Future<void> _onBackPressed(HablarBackPressed event, Emitter<HablarMainState> emit) async {
    if (state.isNavigating) return;
    await _navigator.back();
  }

  Future<void> _loadDictionaryCount(Emitter<HablarMainState> emit) async {
    try {
      final PersonalDictionary dictionary = await _getPersonalDictionaryUseCase.execute(const NoParams());
      if (isClosed) return;
      emit(state.copyWith(dictionaryCount: dictionary.words.length));
    } on Exception catch (_) {
      // The entry stays usable without a counter.
      if (isClosed) return;
      emit(state.copyWith(dictionaryCount: null));
    }
  }
}
