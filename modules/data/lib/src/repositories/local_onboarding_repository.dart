import 'package:core/core.dart';
import 'package:domain/domain.dart';

import '../providers/providers.dart';

final class LocalOnboardingRepository implements OnboardingRepository {
  static const String _completedKey = 'onboarding_complete';

  final LocalStorageProvider _localStorageProvider;

  const LocalOnboardingRepository({
    required LocalStorageProvider localStorageProvider,
  }) : _localStorageProvider = localStorageProvider;

  @override
  Future<bool> isCompleted() async {
    try {
      final bool? isCompleted = await _localStorageProvider.getBool(_completedKey);
      return isCompleted ?? false;
    } on LocalStorageException catch (_) {
      throw const OnboardingStatusReadException();
    } on Exception catch (_) {
      throw const AppException.unknown();
    }
  }

  @override
  Future<void> markCompleted() async {
    try {
      await _localStorageProvider.setBool(_completedKey, value: true);
    } on LocalStorageException catch (_) {
      throw const OnboardingStatusWriteException();
    } on Exception catch (_) {
      throw const AppException.unknown();
    }
  }
}
