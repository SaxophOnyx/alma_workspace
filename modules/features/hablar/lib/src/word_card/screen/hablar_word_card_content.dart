import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../shared/misc/hablar_exception_mapper.dart';
import '../bloc/hablar_word_card_bloc.dart';
import '../widgets/word_card.dart';

class HablarWordCardContent extends StatelessWidget {
  const HablarWordCardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final HablarWordCardBloc bloc = context.read<HablarWordCardBloc>();
    final AppTranslations t = context.translations;

    return AppScaffold(
      onBack: () => bloc.add(const WordCardBackPressed()),
      runningHead: t.hablar.title,
      body: BlocBuilder<HablarWordCardBloc, HablarWordCardState>(
        buildWhen: (HablarWordCardState previous, HablarWordCardState current) =>
            previous.isLoading != current.isLoading ||
            previous.word != current.word ||
            previous.isInDictionary != current.isInDictionary ||
            previous.isAdding != current.isAdding ||
            previous.error != current.error,
        builder: (BuildContext context, HablarWordCardState state) {
          if (state.isLoading) return const AppLoadingPulse();

          final LunfardoWord? word = state.word;
          final Exception? error = state.error;
          final String? errorText = error == null ? null : HablarExceptionMapper.map(error, t);

          if (word == null) {
            return Padding(
              padding: const EdgeInsets.all(AppDimens.screenPadding),
              child: AppText(
                text: errorText ?? t.hablar.errors.unknown,
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
            child: WordCard(
              word: word,
              isInDictionary: state.isInDictionary,
              isAdding: state.isAdding,
              errorText: errorText,
              onAddPressed: () => bloc.add(const AddPressed()),
              onOpenTextPressed: () => bloc.add(const OpenTextPressed()),
            ),
          );
        },
      ),
    );
  }
}
