import 'package:domain/domain.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../navigation/hablar_navigator.dart';

part 'hablar_dictionary_event.dart';
part 'hablar_dictionary_state.dart';

class HablarDictionaryBloc extends Bloc<HablarDictionaryEvent, HablarDictionaryState> {
  final GetPersonalDictionaryUseCase _getPersonalDictionaryUseCase;
  final HablarNavigator _navigator;

  HablarDictionaryBloc({
    required GetPersonalDictionaryUseCase getPersonalDictionaryUseCase,
    required HablarNavigator navigator,
  }) : _getPersonalDictionaryUseCase = getPersonalDictionaryUseCase,
       _navigator = navigator,
       super(const HablarDictionaryState()) {
    on<DictionaryStarted>(_onStarted);
    on<WordPressed>(_onWordPressed);
    on<DictionaryBackPressed>(_onBackPressed);
  }

  Future<void> _onStarted(DictionaryStarted event, Emitter<HablarDictionaryState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final PersonalDictionary dictionary = await _getPersonalDictionaryUseCase.execute(const NoParams());
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, dictionary: dictionary));
    } on Exception catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, dictionary: null, error: e));
    }
  }

  Future<void> _onWordPressed(WordPressed event, Emitter<HablarDictionaryState> emit) async {
    if (state.isNavigating) return;
    emit(state.copyWith(isNavigating: true));

    try {
      await _navigator.openWordCard(event.wordId);
    } on Exception catch (_) {
      // Stay usable; the user can tap again.
    }
    if (isClosed) return;

    emit(state.copyWith(isNavigating: false));
  }

  Future<void> _onBackPressed(DictionaryBackPressed event, Emitter<HablarDictionaryState> emit) async {
    if (state.isNavigating) return;
    await _navigator.back();
  }
}
