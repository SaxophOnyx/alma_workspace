import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../bloc/respirar_duration_bloc.dart';

class RespirarDurationContent extends StatelessWidget {
  const RespirarDurationContent({super.key});

  @override
  Widget build(BuildContext context) {
    final RespirarDurationBloc bloc = context.read<RespirarDurationBloc>();
    final AppTranslations t = context.translations;

    return AppScaffold(
      onBack: () => bloc.add(const DurationBackPressed()),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppDimens.gapM,
          children: <Widget>[
            for (final SessionDuration duration in SessionDuration.values)
              AppTextButton(
                text: t.respirar.durationMinutes(minutes: duration.value.inMinutes),
                onPressed: () => bloc.add(DurationSelected(duration)),
                style: AppTextButtonStyle.menu,
              ),
          ],
        ),
      ),
    );
  }
}
