import 'package:domain/domain.dart';
import 'package:shared_ui/shared_ui.dart';

import '../navigation/launch_navigator.dart';

part 'launch_event.dart';
part 'launch_state.dart';

class LaunchBloc extends Bloc<LaunchEvent, LaunchState> {
  final GetOnboardingCompletedUseCase _getOnboardingCompletedUseCase;
  final LaunchNavigator _navigator;
  final Duration _brandDuration;

  LaunchBloc({
    required GetOnboardingCompletedUseCase getOnboardingCompletedUseCase,
    required LaunchNavigator navigator,
    Duration brandDuration = AppMotions.launchBrand,
  }) : _getOnboardingCompletedUseCase = getOnboardingCompletedUseCase,
       _navigator = navigator,
       _brandDuration = brandDuration,
       super(const LaunchState()) {
    on<LaunchStarted>(_onLaunchStarted);
  }

  Future<void> _onLaunchStarted(LaunchStarted event, Emitter<LaunchState> emit) async {
    if (state.isChecking) return;
    emit(state.copyWith(isChecking: true));

    bool isOnboardingCompleted;
    try {
      isOnboardingCompleted = await _getOnboardingCompletedUseCase.execute(const NoParams());
    } on Exception catch (_) {
      isOnboardingCompleted = false;
    }
    if (isClosed) return;

    if (isOnboardingCompleted) {
      await _navigator.openHome();
    } else {
      // First launch: let "Alma" appear on black before the onboarding begins.
      await Future<void>.delayed(_brandDuration);
      if (isClosed) return;
      await _navigator.openOnboarding();
    }
  }
}
