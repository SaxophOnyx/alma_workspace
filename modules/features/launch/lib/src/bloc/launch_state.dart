part of 'launch_bloc.dart';

final class LaunchState {
  final bool isChecking;

  const LaunchState({
    this.isChecking = false,
  });

  LaunchState copyWith({
    bool? isChecking,
  }) {
    return LaunchState(
      isChecking: isChecking ?? this.isChecking,
    );
  }
}
