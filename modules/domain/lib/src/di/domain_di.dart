import 'package:core/core.dart';

import '../repositories/repositories.dart';
import '../services/services.dart';
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
    locator.registerLazySingleton<GetBreathingPatternUseCase>(
      () => GetBreathingPatternUseCase(
        breathingPatternRepository: locator<BreathingPatternRepository>(),
      ),
    );
    locator.registerLazySingleton<GetRandomQuoteUseCase>(
      () => GetRandomQuoteUseCase(
        quoteRepository: locator<QuoteRepository>(),
      ),
    );
    locator.registerLazySingleton<PlayPhaseHapticUseCase>(
      () => PlayPhaseHapticUseCase(
        hapticFeedbackService: locator<HapticFeedbackService>(),
      ),
    );
    locator.registerLazySingleton<SetScreenAwakeUseCase>(
      () => SetScreenAwakeUseCase(
        screenAwakeService: locator<ScreenAwakeService>(),
      ),
    );
  }
}
