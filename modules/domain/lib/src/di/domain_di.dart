import 'package:core/core.dart';

import '../repositories/repositories.dart';
import '../use_cases/use_cases.dart';

final class DomainDI {
  const DomainDI._();

  static void initDependencies(GetIt locator) {
    _initUseCases(locator);
  }

  static void _initUseCases(GetIt locator) {
    locator.registerLazySingleton<GetOnboardingCompletedUseCase>(
      () => GetOnboardingCompletedUseCase(
        onboardingRepository: locator<OnboardingRepository>(),
      ),
    );
    locator.registerLazySingleton<CompleteOnboardingUseCase>(
      () => CompleteOnboardingUseCase(
        onboardingRepository: locator<OnboardingRepository>(),
      ),
    );
  }
}
