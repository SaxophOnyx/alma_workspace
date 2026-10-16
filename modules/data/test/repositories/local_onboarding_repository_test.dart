import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLocalStorageProvider extends Mock implements LocalStorageProvider {}

const String _key = 'onboarding_complete';

void main() {
  late _MockLocalStorageProvider provider;
  late LocalOnboardingRepository repository;

  setUp(() {
    provider = _MockLocalStorageProvider();
    repository = LocalOnboardingRepository(localStorageProvider: provider);
  });

  group('isCompleted', () {
    test('returns false when the flag was never written', () async {
      when(() => provider.getBool(_key)).thenAnswer((_) async => null);

      expect(await repository.isCompleted(), isFalse);
      verify(() => provider.getBool(_key)).called(1);
      verifyNoMoreInteractions(provider);
    });

    test('returns true when the stored flag is true', () async {
      when(() => provider.getBool(_key)).thenAnswer((_) async => true);

      expect(await repository.isCompleted(), isTrue);
    });

    test('returns false when the stored flag is false', () async {
      when(() => provider.getBool(_key)).thenAnswer((_) async => false);

      expect(await repository.isCompleted(), isFalse);
    });

    test('maps a read LocalStorageException to OnboardingStatusReadException', () async {
      when(() => provider.getBool(_key)).thenThrow(const LocalStorageException(LocalStorageOperation.read));

      await expectLater(repository.isCompleted(), throwsA(isA<OnboardingStatusReadException>()));
    });

    test('maps an unexpected exception to AppException.unknown', () async {
      when(() => provider.getBool(_key)).thenThrow(Exception('boom'));

      await expectLater(
        repository.isCompleted(),
        throwsA(
          isA<AppException>()
              .having((AppException e) => e.message, 'message', const AppException.unknown().message)
              .having((AppException e) => e, 'type', isNot(isA<OnboardingStatusReadException>())),
        ),
      );
    });
  });

  group('markCompleted', () {
    test('writes true under the onboarding_complete key', () async {
      when(() => provider.setBool(_key, value: true)).thenAnswer((_) async {});

      await repository.markCompleted();

      verify(() => provider.setBool(_key, value: true)).called(1);
      verifyNoMoreInteractions(provider);
    });

    test('maps a write LocalStorageException to OnboardingStatusWriteException', () async {
      when(() => provider.setBool(_key, value: true))
          .thenThrow(const LocalStorageException(LocalStorageOperation.write));

      await expectLater(repository.markCompleted(), throwsA(isA<OnboardingStatusWriteException>()));
    });

    test('maps an unexpected exception to AppException.unknown', () async {
      when(() => provider.setBool(_key, value: true)).thenThrow(Exception('boom'));

      await expectLater(
        repository.markCompleted(),
        throwsA(
          isA<AppException>()
              .having((AppException e) => e.message, 'message', const AppException.unknown().message)
              .having((AppException e) => e, 'type', isNot(isA<OnboardingStatusWriteException>())),
        ),
      );
    });
  });
}
