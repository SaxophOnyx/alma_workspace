part of 'respirar_duration_bloc.dart';

final class RespirarDurationState {
  final bool isNavigating;

  const RespirarDurationState({
    this.isNavigating = false,
  });

  RespirarDurationState copyWith({
    bool? isNavigating,
  }) {
    return RespirarDurationState(
      isNavigating: isNavigating ?? this.isNavigating,
    );
  }
}
