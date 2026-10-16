part of 'respirar_modes_bloc.dart';

final class RespirarModesState {
  final bool isNavigating;

  const RespirarModesState({
    this.isNavigating = false,
  });

  RespirarModesState copyWith({
    bool? isNavigating,
  }) {
    return RespirarModesState(
      isNavigating: isNavigating ?? this.isNavigating,
    );
  }
}
