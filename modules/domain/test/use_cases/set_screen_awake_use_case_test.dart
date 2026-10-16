import 'package:domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockScreenAwakeService extends Mock implements ScreenAwakeService {}

void main() {
  late _MockScreenAwakeService service;
  late SetScreenAwakeUseCase useCase;

  setUp(() {
    service = _MockScreenAwakeService();
    useCase = SetScreenAwakeUseCase(screenAwakeService: service);
    when(() => service.setEnabled(enabled: any(named: 'enabled'))).thenAnswer((_) async {});
  });

  group('execute', () {
    test('enables keeping the screen awake', () async {
      await useCase.execute(const SetScreenAwakeParams(enabled: true));

      verify(() => service.setEnabled(enabled: true)).called(1);
      verifyNoMoreInteractions(service);
    });

    test('disables keeping the screen awake', () async {
      await useCase.execute(const SetScreenAwakeParams(enabled: false));

      verify(() => service.setEnabled(enabled: false)).called(1);
      verifyNoMoreInteractions(service);
    });

    test('rethrows errors from the service', () async {
      final Exception exception = Exception('boom');
      when(() => service.setEnabled(enabled: true)).thenThrow(exception);

      await expectLater(useCase.execute(const SetScreenAwakeParams(enabled: true)), throwsA(same(exception)));
    });
  });
}
