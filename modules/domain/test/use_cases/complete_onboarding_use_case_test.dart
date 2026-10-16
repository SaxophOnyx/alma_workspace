import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockOnboardingRepository extends Mock implements OnboardingRepository {}

void main() {
  late _MockOnboardingRepository repository;
  late CompleteOnboardingUseCase useCase;

  setUp(() {
    repository = _MockOnboardingRepository();
    useCase = CompleteOnboardingUseCase(onboardingRepository: repository);
  });

  group('execute', () {
    test('marks onboarding as completed exactly once', () async {
      when(() => repository.markCompleted()).thenAnswer((_) async {});

      await useCase.execute(const NoParams());

      verify(() => repository.markCompleted()).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('does not read the flag before writing it', () async {
      when(() => repository.markCompleted()).thenAnswer((_) async {});

      await useCase.execute(const NoParams());

      verifyNever(() => repository.isCompleted());
    });

    test('rethrows OnboardingStatusWriteException from the repository', () async {
      const OnboardingStatusWriteException exception = OnboardingStatusWriteException();
      when(() => repository.markCompleted()).thenThrow(exception);

      await expectLater(useCase.execute(const NoParams()), throwsA(same(exception)));
    });

    test('rethrows unknown AppException from the repository', () async {
      when(() => repository.markCompleted()).thenThrow(const AppException.unknown());

      await expectLater(useCase.execute(const NoParams()), throwsA(isA<AppException>()));
    });
  });
}
