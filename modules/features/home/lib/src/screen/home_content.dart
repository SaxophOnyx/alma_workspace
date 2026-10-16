import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../bloc/home_bloc.dart';
import '../misc/home_entry.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeBloc bloc = context.read<HomeBloc>();
    final AppTranslations t = context.translations;

    return PopScope(
      canPop: false,
      child: AppScaffold(
        runningHead: t.common.brand,
        body: Column(
          children: <Widget>[
            const Spacer(),
            BlocBuilder<HomeBloc, HomeState>(
              builder: (BuildContext context, HomeState state) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: AppDimens.gapL,
                  children: <Widget>[
                    for (final HomeEntry entry in HomeEntry.values)
                      AppFadeIn(
                        delay: AppMotions.staggerStep * (entry.index + 1),
                        child: AppTextButton(
                          text: switch (entry) {
                            HomeEntry.respirar => t.home.respirar,
                            HomeEntry.hablar => t.home.hablar,
                            HomeEntry.leer => t.home.leer,
                          },
                          onPressed: () => bloc.add(EntryPressed(entry)),
                          style: AppTextButtonStyle.navigation,
                          isHighlighted: state.highlightedEntry == entry,
                        ),
                      ),
                  ],
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.gapXl),
              child: AppFadeIn(
                delay: AppMotions.staggerInterval,
                child: AppText(
                  text: t.common.tagline,
                  style: context.appTexts.quote,
                  textAlign: TextAlign.center,
                  color: context.appColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
