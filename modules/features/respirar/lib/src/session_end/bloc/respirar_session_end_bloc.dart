import 'package:domain/domain.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../navigation/respirar_navigator.dart';

part 'respirar_session_end_event.dart';
part 'respirar_session_end_state.dart';

class RespirarSessionEndBloc extends Bloc<RespirarSessionEndEvent, RespirarSessionEndState> {
  final GetRandomQuoteUseCase _getRandomQuoteUseCase;
  final RespirarNavigator _navigator;

  RespirarSessionEndBloc({
    required GetRandomQuoteUseCase getRandomQuoteUseCase,
    required RespirarNavigator navigator,
  }) : _getRandomQuoteUseCase = getRandomQuoteUseCase,
       _navigator = navigator,
       super(const RespirarSessionEndState()) {
    on<SessionEndStarted>(_onStarted);
    on<QuotePressed>(_onQuotePressed);
    on<HomePressed>(_onHomePressed);
    on<SessionEndBackPressed>(_onBackPressed);
  }

  Future<void> _onStarted(SessionEndStarted event, Emitter<RespirarSessionEndState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final Quote? quote = await _getRandomQuoteUseCase.execute(const NoParams());
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, quote: quote));
    } on Exception catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, quote: null, error: e));
    }
  }

  Future<void> _onQuotePressed(QuotePressed event, Emitter<RespirarSessionEndState> emit) async {
    final Quote? quote = state.quote;
    if (quote == null || state.isNavigating) return;
    emit(state.copyWith(isNavigating: true));

    try {
      await _navigator.openText(quote.textId);
    } on Exception catch (_) {
      // Stay usable; the user can tap again.
    }
    if (isClosed) return;

    emit(state.copyWith(isNavigating: false));
  }

  Future<void> _onHomePressed(HomePressed event, Emitter<RespirarSessionEndState> emit) async {
    if (state.isNavigating) return;
    emit(state.copyWith(isNavigating: true));

    await _navigator.openHome();
  }

  Future<void> _onBackPressed(SessionEndBackPressed event, Emitter<RespirarSessionEndState> emit) async {
    if (state.isNavigating) return;
    emit(state.copyWith(isNavigating: true));

    await _navigator.close();
  }
}
