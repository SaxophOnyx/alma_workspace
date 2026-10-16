part of 'respirar_leave_confirmation_bloc.dart';

final class RespirarLeaveConfirmationState {
  final bool isResolving;

  const RespirarLeaveConfirmationState({
    this.isResolving = false,
  });

  RespirarLeaveConfirmationState copyWith({
    bool? isResolving,
  }) {
    return RespirarLeaveConfirmationState(
      isResolving: isResolving ?? this.isResolving,
    );
  }
}
