import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../bloc/respirar_modes_bloc.dart';

class RespirarModesContent extends StatelessWidget {
  const RespirarModesContent({super.key});

  @override
  Widget build(BuildContext context) {
    final RespirarModesBloc bloc = context.read<RespirarModesBloc>();
    final AppTranslations t = context.translations;

    return AppScaffold(
      onBack: () => bloc.add(const ModesBackPressed()),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppDimens.gapM,
          children: <Widget>[
            AppText(
              text: t.respirar.title,
              style: context.appTexts.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.gapL),
            for (final BreathingMode mode in BreathingMode.values)
              AppTextButton(
                text: switch (mode) {
                  BreathingMode.compas => t.respirar.modes.compas,
                  BreathingMode.pausa => t.respirar.modes.pausa,
                  BreathingMode.caminar => t.respirar.modes.caminar,
                  BreathingMode.abrazo => t.respirar.modes.abrazo,
                },
                onPressed: () => bloc.add(ModeSelected(mode)),
                style: AppTextButtonStyle.menu,
              ),
          ],
        ),
      ),
    );
  }
}
