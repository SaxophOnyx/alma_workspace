import 'package:domain/domain.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../navigation/leer_navigator.dart';

part 'leer_text_list_event.dart';
part 'leer_text_list_state.dart';

class LeerTextListBloc extends Bloc<LeerTextListEvent, LeerTextListState> {
  final GetTextsUseCase _getTextsUseCase;
  final LeerNavigator _navigator;

  LeerTextListBloc({
    required GetTextsUseCase getTextsUseCase,
    required LeerNavigator navigator,
  }) : _getTextsUseCase = getTextsUseCase,
       _navigator = navigator,
       super(const LeerTextListState()) {
    on<TextListStarted>(_onStarted);
    on<TextPressed>(_onTextPressed);
    on<TextListBackPressed>(_onBackPressed);
  }

  Future<void> _onStarted(TextListStarted event, Emitter<LeerTextListState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final List<TangoText> texts = await _getTextsUseCase.execute(const NoParams());
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, texts: texts));
    } on Exception catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, error: e));
    }
  }

  Future<void> _onTextPressed(TextPressed event, Emitter<LeerTextListState> emit) async {
    if (state.isNavigating) return;
    emit(state.copyWith(isNavigating: true));

    try {
      await _navigator.openContext(event.textId);
    } on Exception catch (_) {
      // Stay usable; the user can tap again.
    }
    if (isClosed) return;

    emit(state.copyWith(isNavigating: false));
  }

  Future<void> _onBackPressed(TextListBackPressed event, Emitter<LeerTextListState> emit) async {
    if (state.isNavigating) return;
    await _navigator.back();
  }
}
