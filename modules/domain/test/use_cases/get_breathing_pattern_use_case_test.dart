import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockBreathingPatternRepository extends Mock implements BreathingPatternRepository {}

const BreathingPattern _abrazo = BreathingPattern(
  mode: BreathingMode.abrazo,
  phases: <BreathingPhase>[
    BreathingPhase(type: BreathingPhaseType.inhale, duration: Duration(seconds: 5)),
  ],
);

void main() {
  late _MockBreathingPatternRepository repository;
  late GetBreathingPatternUseCase useCase;

  setUp(() {
    repository = _MockBreathingPatternRepository();
    useCase = GetBreathingPatternUseCase(breathingPatternRepository: repository);
  });

  group('execute', () {
    test('returns the pattern for the requested mode', () async {
      when(() => repository.getPattern(BreathingMode.abrazo)).thenAnswer((_) async => _abrazo);

      final BreathingPattern result = await useCase.execute(
        const GetBreathingPatternParams(mode: BreathingMode.abrazo),
      );

      expect(result, same(_abrazo));
      verify(() => repository.getPattern(BreathingMode.abrazo)).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('rethrows BreathingPatternLoadException from the repository', () async {
      const BreathingPatternLoadException exception = BreathingPatternLoadException();
      when(() => repository.getPattern(BreathingMode.compas)).thenThrow(exception);

      await expectLater(
        useCase.execute(const GetBreathingPatternParams(mode: BreathingMode.compas)),
        throwsA(same(exception)),
      );
    });

    test('rethrows unknown AppException from the repository', () async {
      when(() => repository.getPattern(BreathingMode.pausa)).thenThrow(const AppException.unknown());

      await expectLater(
        useCase.execute(const GetBreathingPatternParams(mode: BreathingMode.pausa)),
        throwsA(isA<AppException>()),
      );
    });
  });
}
