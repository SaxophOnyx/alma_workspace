import 'package:domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockHapticFeedbackService extends Mock implements HapticFeedbackService {}

void main() {
  late _MockHapticFeedbackService service;
  late PlayPhaseHapticUseCase useCase;

  setUp(() {
    service = _MockHapticFeedbackService();
    useCase = PlayPhaseHapticUseCase(hapticFeedbackService: service);
  });

  group('execute', () {
    test('emits exactly one pulse', () async {
      when(() => service.pulse()).thenAnswer((_) async {});

      await useCase.execute(const NoParams());

      verify(() => service.pulse()).called(1);
      verifyNoMoreInteractions(service);
    });

    test('rethrows errors from the service', () async {
      final Exception exception = Exception('boom');
      when(() => service.pulse()).thenThrow(exception);

      await expectLater(useCase.execute(const NoParams()), throwsA(same(exception)));
    });
  });
}
