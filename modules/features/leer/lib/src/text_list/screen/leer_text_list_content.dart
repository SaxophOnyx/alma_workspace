import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../shared/misc/leer_exception_mapper.dart';
import '../bloc/leer_text_list_bloc.dart';
import '../widgets/text_list_item.dart';

class LeerTextListContent extends StatelessWidget {
  const LeerTextListContent({super.key});

  @override
  Widget build(BuildContext context) {
    final LeerTextListBloc bloc = context.read<LeerTextListBloc>();
    final AppTranslations t = context.translations;

    return AppScaffold(
      onBack: () => bloc.add(const TextListBackPressed()),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(AppDimens.screenPadding),
            child: AppText(
              text: t.leer.title,
              style: context.appTexts.title,
            ),
          ),
          Expanded(
            child: BlocBuilder<LeerTextListBloc, LeerTextListState>(
              buildWhen: (LeerTextListState previous, LeerTextListState current) =>
                  previous.isLoading != current.isLoading ||
                  previous.texts != current.texts ||
                  previous.error != current.error,
              builder: (BuildContext context, LeerTextListState state) {
                if (state.isLoading) return const SizedBox.shrink();

                final Exception? error = state.error;
                if (error != null) {
                  return Padding(
                    padding: const EdgeInsets.all(AppDimens.screenPadding),
                    child: AppText(
                      text: LeerExceptionMapper.map(error, t),
                      style: context.appTexts.body,
                      maxLines: null,
                      color: context.appColors.textSecondary,
                    ),
                  );
                }

                return AppFadeIn(
                  duration: AppMotions.durationMedium,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenPadding),
                    itemCount: state.texts.length,
                    itemBuilder: (BuildContext context, int index) {
                      final TangoText text = state.texts[index];
                      return TextListItem(
                        title: text.title,
                        year: text.year,
                        onPressed: () => bloc.add(TextPressed(text.id)),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
