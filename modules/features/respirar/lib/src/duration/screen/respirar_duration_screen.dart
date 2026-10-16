import 'package:auto_route/auto_route.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../navigation/respirar_navigator.dart';
import '../bloc/respirar_duration_bloc.dart';
import 'respirar_duration_content.dart';

@RoutePage()
class RespirarDurationScreen extends StatelessWidget {
  final BreathingMode mode;

  const RespirarDurationScreen({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RespirarDurationBloc>(
      create: (BuildContext context) {
        return RespirarDurationBloc(
          mode: mode,
          navigator: context.resolve<RespirarNavigator>(),
        );
      },
      child: RespirarDurationContent(mode: mode),
    );
  }
}
