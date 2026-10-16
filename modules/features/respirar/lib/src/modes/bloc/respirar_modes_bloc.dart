import 'package:domain/domain.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../navigation/respirar_navigator.dart';

part 'respirar_modes_event.dart';
part 'respirar_modes_state.dart';

class RespirarModesBloc extends Bloc<RespirarModesEvent, RespirarModesState> {
  final RespirarNavigator _navigator;

  RespirarModesBloc({
    required RespirarNavigator navigator,
  }) : _navigator = navigator,
       super(const RespirarModesState()) {
    on<ModeSelected>(_onModeSelected);
    on<ModesBackPressed>(_onBackPressed);
  }

  Future<void> _onModeSelected(ModeSelected event, Emitter<RespirarModesState> emit) async {
    if (state.isNavigating) return;
    emit(state.copyWith(isNavigating: true));

    try {
      await _navigator.openDurationSelection(event.mode);
    } on Exception catch (_) {
      // Stay usable; the user can tap again.
    }
    if (isClosed) return;

    emit(state.copyWith(isNavigating: false));
  }

  Future<void> _onBackPressed(ModesBackPressed event, Emitter<RespirarModesState> emit) async {
    if (state.isNavigating) return;
    await _navigator.back();
  }
}
