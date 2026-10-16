import 'package:domain/domain.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../navigation/leer_navigator.dart';

part 'leer_context_event.dart';
part 'leer_context_state.dart';

class LeerContextBloc extends Bloc<LeerContextEvent, LeerContextState> {
  final String _textId;
  final GetTextUseCase _getTextUseCase;
  final LeerNavigator _navigator;

  LeerContextBloc({
    required String textId,
    required GetTextUseCase getTextUseCase,
    required LeerNavigator navigator,
  }) : _textId = textId,
       _getTextUseCase = getTextUseCase,
       _navigator = navigator,
       super(const LeerContextState()) {
    on<ContextStarted>(_onStarted);
    on<ReadPressed>(_onReadPressed);
    on<ContextBackPressed>(_onBackPressed);
  }

  Future<void> _onStarted(ContextStarted event, Emitter<LeerContextState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final TangoText text = await _getTextUseCase.execute(GetTextParams(textId: _textId));
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, text: text));
    } on Exception catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, text: null, error: e));
    }
  }

  Future<void> _onReadPressed(ReadPressed event, Emitter<LeerContextState> emit) async {
    final TangoText? text = state.text;
    if (text == null || state.isNavigating) return;
    emit(state.copyWith(isNavigating: true));

    try {
      await _navigator.startReading(text.id);
    } on Exception catch (_) {
      // Stay usable; the user can tap again.
    }
    if (isClosed) return;

    emit(state.copyWith(isNavigating: false));
  }

  Future<void> _onBackPressed(ContextBackPressed event, Emitter<LeerContextState> emit) async {
    if (state.isNavigating) return;
    await _navigator.back();
  }
}
