import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../bloc/respirar_leave_confirmation_bloc.dart';

class RespirarLeaveConfirmationContent extends StatelessWidget {
  // Below the centered point, so the frozen point stays visible above the question.
  static const Alignment _alignment = Alignment(0, 0.4);

  const RespirarLeaveConfirmationContent({super.key});

  @override
  Widget build(BuildContext context) {
    final RespirarLeaveConfirmationBloc bloc = context.read<RespirarLeaveConfirmationBloc>();
    final AppTranslations t = context.translations;

    return Material(
      type: MaterialType.transparency,
      child: Align(
        alignment: _alignment,
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: AppDimens.gapM,
            children: <Widget>[
              AppText(
                text: t.respirar.session.leaveQuestion,
                style: context.appTexts.body,
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: AppDimens.gapL,
                children: <Widget>[
                  AppTextButton(
                    text: t.respirar.session.leave,
                    onPressed: () => bloc.add(const LeavePressed()),
                    style: AppTextButtonStyle.signal,
                  ),
                  AppTextButton(
                    text: t.respirar.session.stay,
                    onPressed: () => bloc.add(const StayPressed()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
