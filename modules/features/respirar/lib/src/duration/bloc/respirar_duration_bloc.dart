import 'package:domain/domain.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../navigation/respirar_navigator.dart';

part 'respirar_duration_event.dart';
part 'respirar_duration_state.dart';

class RespirarDurationBloc extends Bloc<RespirarDurationEvent, RespirarDurationState> {
  final BreathingMode _mode;
  final RespirarNavigator _navigator;

  RespirarDurationBloc({
    required BreathingMode mode,
    required RespirarNavigator navigator,
  }) : _mode = mode,
       _navigator = navigator,
       super(const RespirarDurationState()) {
    on<DurationSelected>(_onDurationSelected);
    on<DurationBackPressed>(_onBackPressed);
  }

  Future<void> _onDurationSelected(DurationSelected event, Emitter<RespirarDurationState> emit) async {
    if (state.isNavigating) return;
    emit(state.copyWith(isNavigating: true));

    try {
      await _navigator.startSession(_mode, event.duration);
    } on Exception catch (_) {
      // Stay usable; the user can tap again.
    }
    if (isClosed) return;

    emit(state.copyWith(isNavigating: false));
  }

  Future<void> _onBackPressed(DurationBackPressed event, Emitter<RespirarDurationState> emit) async {
    if (state.isNavigating) return;
    await _navigator.back();
  }
}
