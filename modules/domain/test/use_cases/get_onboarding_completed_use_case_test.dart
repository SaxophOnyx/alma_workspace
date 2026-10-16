import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockOnboardingRepository extends Mock implements OnboardingRepository {}

void main() {
  late _MockOnboardingRepository repository;
  late GetOnboardingCompletedUseCase useCase;

  setUp(() {
    repository = _MockOnboardingRepository();
    useCase = GetOnboardingCompletedUseCase(onboardingRepository: repository);
  });

  group('execute', () {
    test('returns true when the repository reports onboarding as completed', () async {
      when(() => repository.isCompleted()).thenAnswer((_) async => true);

      final bool result = await useCase.execute(const NoParams());

      expect(result, isTrue);
      verify(() => repository.isCompleted()).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('returns false when the repository reports onboarding as not completed', () async {
      when(() => repository.isCompleted()).thenAnswer((_) async => false);

      final bool result = await useCase.execute(const NoParams());

      expect(result, isFalse);
    });

    test('never writes the flag', () async {
      when(() => repository.isCompleted()).thenAnswer((_) async => false);

      await useCase.execute(const NoParams());

      verifyNever(() => repository.markCompleted());
    });

    test('rethrows OnboardingStatusReadException from the repository', () async {
      const OnboardingStatusReadException exception = OnboardingStatusReadException();
      when(() => repository.isCompleted()).thenThrow(exception);

      await expectLater(useCase.execute(const NoParams()), throwsA(same(exception)));
    });

    test('rethrows unknown AppException from the repository', () async {
      when(() => repository.isCompleted()).thenThrow(const AppException.unknown());

      await expectLater(
        useCase.execute(const NoParams()),
        throwsA(isA<AppException>().having((AppException e) => e.message, 'message', 'Unknown exception')),
      );
    });
  });
}
