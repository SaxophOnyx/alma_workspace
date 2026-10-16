import '../repositories/onboarding_repository.dart';
import 'template_use_cases.dart';

class CompleteOnboardingUseCase implements FutureUseCase<NoParams, void> {
  final OnboardingRepository _onboardingRepository;

  const CompleteOnboardingUseCase({
    required OnboardingRepository onboardingRepository,
  }) : _onboardingRepository = onboardingRepository;

  @override
  Future<void> execute(NoParams input) async {
    await _onboardingRepository.markCompleted();
  }
}
