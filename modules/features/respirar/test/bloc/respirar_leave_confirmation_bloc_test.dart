import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:respirar/src/leave_confirmation/bloc/respirar_leave_confirmation_bloc.dart';
import 'package:respirar/src/navigation/respirar_navigator.dart';

class _MockRespirarNavigator extends Mock implements RespirarNavigator {}

void main() {
  late _MockRespirarNavigator navigator;

  setUp(() {
    navigator = _MockRespirarNavigator();
    when(() => navigator.resolveLeaveConfirmation(leave: any(named: 'leave'))).thenAnswer((_) async {});
  });

  RespirarLeaveConfirmationBloc buildBloc() => RespirarLeaveConfirmationBloc(navigator: navigator);

  Matcher resolving() {
    return isA<RespirarLeaveConfirmationState>().having(
      (RespirarLeaveConfirmationState s) => s.isResolving,
      'isResolving',
      isTrue,
    );
  }

  blocTest<RespirarLeaveConfirmationBloc, RespirarLeaveConfirmationState>(
    'LeavePressed resolves the confirmation with leave',
    build: buildBloc,
    act: (RespirarLeaveConfirmationBloc bloc) => bloc.add(const LeavePressed()),
    expect: () => <Matcher>[resolving()],
    verify: (_) {
      verify(() => navigator.resolveLeaveConfirmation(leave: true)).called(1);
      verifyNoMoreInteractions(navigator);
    },
  );

  blocTest<RespirarLeaveConfirmationBloc, RespirarLeaveConfirmationState>(
    'StayPressed resolves the confirmation with stay',
    build: buildBloc,
    act: (RespirarLeaveConfirmationBloc bloc) => bloc.add(const StayPressed()),
    expect: () => <Matcher>[resolving()],
    verify: (_) {
      verify(() => navigator.resolveLeaveConfirmation(leave: false)).called(1);
      verifyNoMoreInteractions(navigator);
    },
  );

  blocTest<RespirarLeaveConfirmationBloc, RespirarLeaveConfirmationState>(
    'resolves only once when both words are tapped rapidly',
    build: buildBloc,
    act: (RespirarLeaveConfirmationBloc bloc) => bloc
      ..add(const StayPressed())
      ..add(const LeavePressed()),
    expect: () => <Matcher>[resolving()],
    verify: (_) {
      verify(() => navigator.resolveLeaveConfirmation(leave: false)).called(1);
      verifyNever(() => navigator.resolveLeaveConfirmation(leave: true));
    },
  );
}
