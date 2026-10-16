import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../bloc/hablar_main_bloc.dart';
import '../misc/hablar_entry.dart';

class HablarMainContent extends StatelessWidget {
  const HablarMainContent({super.key});

  @override
  Widget build(BuildContext context) {
    final HablarMainBloc bloc = context.read<HablarMainBloc>();
    final AppTranslations t = context.translations;

    return AppScaffold(
      onBack: () => bloc.add(const HablarBackPressed()),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppDimens.gapM,
          children: <Widget>[
            AppText(
              text: t.hablar.title,
              style: context.appTexts.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimens.gapL),
            BlocBuilder<HablarMainBloc, HablarMainState>(
              buildWhen: (HablarMainState previous, HablarMainState current) =>
                  previous.dictionaryCount != current.dictionaryCount,
              builder: (BuildContext context, HablarMainState state) {
                final int? count = state.dictionaryCount;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: AppDimens.gapM,
                  children: <Widget>[
                    for (final HablarEntry entry in HablarEntry.values)
                      AppTextButton(
                        text: switch (entry) {
                          HablarEntry.wordOfTheDay => t.hablar.entries.wordOfTheDay,
                          HablarEntry.dictionary =>
                            count == null
                                ? t.hablar.entries.dictionary
                                : t.hablar.entries.dictionaryWithCount(count: count),
                          HablarEntry.quiz => t.hablar.entries.quiz,
                        },
                        onPressed: () => bloc.add(EntryPressed(entry)),
                        style: AppTextButtonStyle.menu,
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
