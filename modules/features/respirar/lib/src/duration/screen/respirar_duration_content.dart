import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../bloc/respirar_duration_bloc.dart';

class RespirarDurationContent extends StatelessWidget {
  final BreathingMode mode;

  const RespirarDurationContent({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final RespirarDurationBloc bloc = context.read<RespirarDurationBloc>();
    final AppTranslations t = context.translations;

    return AppScaffold(
      onBack: () => bloc.add(const DurationBackPressed()),
      runningHead: t.respirar.title,
      body: AppMenuLayout(
        title: switch (mode) {
          BreathingMode.compas => t.respirar.modes.compas,
          BreathingMode.pausa => t.respirar.modes.pausa,
          BreathingMode.caminar => t.respirar.modes.caminar,
          BreathingMode.abrazo => t.respirar.modes.abrazo,
        },
        items: <Widget>[
          for (final SessionDuration duration in SessionDuration.values)
            AppTextButton(
              text: t.respirar.durationMinutes(minutes: duration.value.inMinutes),
              onPressed: () => bloc.add(DurationSelected(duration)),
              style: AppTextButtonStyle.navigation,
            ),
        ],
      ),
    );
  }
}
