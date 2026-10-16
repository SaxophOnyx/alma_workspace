import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../shared/misc/leer_exception_mapper.dart';
import '../bloc/leer_context_bloc.dart';
import '../widgets/context_card.dart';

class LeerContextContent extends StatelessWidget {
  const LeerContextContent({super.key});

  @override
  Widget build(BuildContext context) {
    final LeerContextBloc bloc = context.read<LeerContextBloc>();
    final AppTranslations t = context.translations;

    return AppScaffold(
      onBack: () => bloc.add(const ContextBackPressed()),
      runningHead: t.leer.title,
      body: BlocBuilder<LeerContextBloc, LeerContextState>(
        buildWhen: (LeerContextState previous, LeerContextState current) =>
            previous.isLoading != current.isLoading ||
            previous.text != current.text ||
            previous.error != current.error,
        builder: (BuildContext context, LeerContextState state) {
          if (state.isLoading) return const AppLoadingPulse();

          final TangoText? text = state.text;
          if (text == null) {
            final Exception? error = state.error;
            return Padding(
              padding: const EdgeInsets.all(AppDimens.screenPadding),
              child: AppText(
                text: error == null ? t.leer.errors.unknown : LeerExceptionMapper.map(error, t),
                style: context.appTexts.body,
                maxLines: null,
                color: context.appColors.textSecondary,
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.screenPadding,
              AppDimens.gapXl,
              AppDimens.screenPadding,
              AppDimens.gapXxl,
            ),
            child: ContextCard(
              text: text,
              onReadPressed: () => bloc.add(const ReadPressed()),
            ),
          );
        },
      ),
    );
  }
}
