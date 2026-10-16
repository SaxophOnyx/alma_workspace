import 'package:domain/domain.dart';
import 'package:shared_ui/shared_ui.dart';

import '../navigation/onboarding_navigator.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final CompleteOnboardingUseCase _completeOnboardingUseCase;
  final OnboardingNavigator _navigator;
  final Duration _enterHighlightDuration;

  OnboardingBloc({
    required CompleteOnboardingUseCase completeOnboardingUseCase,
    required OnboardingNavigator navigator,
    Duration enterHighlightDuration = AppMotions.durationHighlight,
  }) : _completeOnboardingUseCase = completeOnboardingUseCase,
       _navigator = navigator,
       _enterHighlightDuration = enterHighlightDuration,
       super(const OnboardingState()) {
    on<SkipPressed>(_onSkipPressed);
    on<EnterPressed>(_onEnterPressed);
  }

  Future<void> _onSkipPressed(SkipPressed event, Emitter<OnboardingState> emit) async {
    if (state.isCompleting) return;
    emit(state.copyWith(isCompleting: true));

    await _markCompleted();
    if (isClosed) return;

    await _navigator.openHome();
  }

  Future<void> _onEnterPressed(EnterPressed event, Emitter<OnboardingState> emit) async {
    if (state.isCompleting) return;
    emit(state.copyWith(isCompleting: true, isEnterHighlighted: true));

    // Keep the gold highlight visible for its full duration, even if saving is faster.
    await Future.wait<void>(<Future<void>>[
      _markCompleted(),
      Future<void>.delayed(_enterHighlightDuration),
    ]);
    if (isClosed) return;

    await _navigator.openHome();
  }

  Future<void> _markCompleted() async {
    try {
      await _completeOnboardingUseCase.execute(const NoParams());
    } on Exception catch (_) {
      // A failed write must not trap the user in onboarding; at worst it is shown again next launch.
    }
  }
}
