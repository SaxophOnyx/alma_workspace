part of 'respirar_leave_confirmation_bloc.dart';

sealed class RespirarLeaveConfirmationEvent {
  const RespirarLeaveConfirmationEvent();
}

final class LeavePressed extends RespirarLeaveConfirmationEvent {
  const LeavePressed();
}

final class StayPressed extends RespirarLeaveConfirmationEvent {
  const StayPressed();
}
