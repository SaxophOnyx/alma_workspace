part of 'onboarding_bloc.dart';

final class OnboardingState {
  final bool isCompleting;
  final bool isEnterHighlighted;

  const OnboardingState({
    this.isCompleting = false,
    this.isEnterHighlighted = false,
  });

  OnboardingState copyWith({
    bool? isCompleting,
    bool? isEnterHighlighted,
  }) {
    return OnboardingState(
      isCompleting: isCompleting ?? this.isCompleting,
      isEnterHighlighted: isEnterHighlighted ?? this.isEnterHighlighted,
    );
  }
}
