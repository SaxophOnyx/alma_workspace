import 'package:auto_route/auto_route.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../navigation/respirar_navigator.dart';
import '../bloc/respirar_session_bloc.dart';
import 'respirar_session_content.dart';

@RoutePage()
class RespirarSessionScreen extends StatelessWidget {
  final BreathingMode mode;
  final SessionDuration duration;

  const RespirarSessionScreen({
    super.key,
    required this.mode,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RespirarSessionBloc>(
      create: (BuildContext context) {
        return RespirarSessionBloc(
          mode: mode,
          duration: duration,
          getBreathingPatternUseCase: context.resolve<GetBreathingPatternUseCase>(),
          playPhaseHapticUseCase: context.resolve<PlayPhaseHapticUseCase>(),
          setScreenAwakeUseCase: context.resolve<SetScreenAwakeUseCase>(),
          navigator: context.resolve<RespirarNavigator>(),
        )..add(const SessionStarted());
      },
      child: const RespirarSessionContent(),
    );
  }
}
