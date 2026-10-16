import 'package:shared_ui/shared_ui.dart';

import '../../navigation/respirar_navigator.dart';

part 'respirar_leave_confirmation_event.dart';
part 'respirar_leave_confirmation_state.dart';

class RespirarLeaveConfirmationBloc extends Bloc<RespirarLeaveConfirmationEvent, RespirarLeaveConfirmationState> {
  final RespirarNavigator _navigator;

  RespirarLeaveConfirmationBloc({
    required RespirarNavigator navigator,
  }) : _navigator = navigator,
       super(const RespirarLeaveConfirmationState()) {
    on<LeavePressed>(_onLeavePressed);
    on<StayPressed>(_onStayPressed);
  }

  Future<void> _onLeavePressed(LeavePressed event, Emitter<RespirarLeaveConfirmationState> emit) {
    return _resolve(emit, leave: true);
  }

  Future<void> _onStayPressed(StayPressed event, Emitter<RespirarLeaveConfirmationState> emit) {
    return _resolve(emit, leave: false);
  }

  Future<void> _resolve(Emitter<RespirarLeaveConfirmationState> emit, {required bool leave}) async {
    if (state.isResolving) return;
    emit(state.copyWith(isResolving: true));

    await _navigator.resolveLeaveConfirmation(leave: leave);
  }
}
