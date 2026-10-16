part of 'onboarding_bloc.dart';

sealed class OnboardingEvent {
  const OnboardingEvent();
}

final class SkipPressed extends OnboardingEvent {
  const SkipPressed();
}

final class EnterPressed extends OnboardingEvent {
  const EnterPressed();
}
