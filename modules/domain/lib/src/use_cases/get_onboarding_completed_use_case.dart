import '../repositories/onboarding_repository.dart';
import 'template_use_cases.dart';

class GetOnboardingCompletedUseCase implements FutureUseCase<NoParams, bool> {
  final OnboardingRepository _onboardingRepository;

  const GetOnboardingCompletedUseCase({
    required OnboardingRepository onboardingRepository,
  }) : _onboardingRepository = onboardingRepository;

  @override
  Future<bool> execute(NoParams input) async {
    return await _onboardingRepository.isCompleted();
  }
}
