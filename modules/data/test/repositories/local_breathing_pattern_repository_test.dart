import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockContentProvider extends Mock implements ContentProvider {}

const List<BreathingPatternEntity> _entities = <BreathingPatternEntity>[
  BreathingPatternEntity(
    mode: 'compas',
    phases: <BreathingPhaseEntity>[BreathingPhaseEntity(type: 'inhale', durationMs: 6000)],
  ),
  BreathingPatternEntity(
    mode: 'abrazo',
    phases: <BreathingPhaseEntity>[BreathingPhaseEntity(type: 'exhale', durationMs: 6000)],
  ),
];

void main() {
  late _MockContentProvider provider;
  late LocalBreathingPatternRepository repository;

  setUp(() {
    provider = _MockContentProvider();
    repository = LocalBreathingPatternRepository(contentProvider: provider);
  });

  group('getPattern', () {
    test('returns the mapped pattern for the requested mode', () async {
      when(() => provider.loadBreathingPatterns()).thenAnswer((_) async => _entities);

      final BreathingPattern pattern = await repository.getPattern(BreathingMode.abrazo);

      expect(pattern.mode, BreathingMode.abrazo);
      expect(pattern.phases.single.type, BreathingPhaseType.exhale);
      verify(() => provider.loadBreathingPatterns()).called(1);
      verifyNoMoreInteractions(provider);
    });

    test('loads content only once across calls', () async {
      when(() => provider.loadBreathingPatterns()).thenAnswer((_) async => _entities);

      await repository.getPattern(BreathingMode.compas);
      clearInteractions(provider);
      final BreathingPattern second = await repository.getPattern(BreathingMode.abrazo);

      expect(second.mode, BreathingMode.abrazo);
      verifyNever(() => provider.loadBreathingPatterns());
    });

    test('retries loading after a failed load', () async {
      when(() => provider.loadBreathingPatterns())
          .thenThrow(const ContentLoadException(ContentType.breathingPatterns));
      await expectLater(repository.getPattern(BreathingMode.compas), throwsA(isA<BreathingPatternLoadException>()));

      when(() => provider.loadBreathingPatterns()).thenAnswer((_) async => _entities);
      final BreathingPattern pattern = await repository.getPattern(BreathingMode.compas);

      expect(pattern.mode, BreathingMode.compas);
    });

    test('throws BreathingPatternLoadException when the mode is missing from content', () async {
      when(() => provider.loadBreathingPatterns()).thenAnswer((_) async => _entities);

      await expectLater(repository.getPattern(BreathingMode.pausa), throwsA(isA<BreathingPatternLoadException>()));
    });

    test('throws BreathingPatternLoadException when content is empty', () async {
      when(() => provider.loadBreathingPatterns()).thenAnswer((_) async => <BreathingPatternEntity>[]);

      await expectLater(repository.getPattern(BreathingMode.compas), throwsA(isA<BreathingPatternLoadException>()));
    });

    test('maps ContentLoadException to BreathingPatternLoadException', () async {
      when(() => provider.loadBreathingPatterns())
          .thenThrow(const ContentLoadException(ContentType.breathingPatterns));

      await expectLater(repository.getPattern(BreathingMode.compas), throwsA(isA<BreathingPatternLoadException>()));
    });

    test('maps malformed content to BreathingPatternLoadException', () async {
      when(() => provider.loadBreathingPatterns()).thenAnswer(
        (_) async => const <BreathingPatternEntity>[
          BreathingPatternEntity(mode: 'tango', phases: <BreathingPhaseEntity>[]),
        ],
      );

      await expectLater(repository.getPattern(BreathingMode.compas), throwsA(isA<BreathingPatternLoadException>()));
    });

    test('maps an unexpected exception to AppException.unknown', () async {
      when(() => provider.loadBreathingPatterns()).thenThrow(Exception('boom'));

      await expectLater(
        repository.getPattern(BreathingMode.compas),
        throwsA(
          isA<AppException>()
              .having((AppException e) => e.message, 'message', const AppException.unknown().message)
              .having((AppException e) => e, 'type', isNot(isA<BreathingPatternLoadException>())),
        ),
      );
    });
  });
}
