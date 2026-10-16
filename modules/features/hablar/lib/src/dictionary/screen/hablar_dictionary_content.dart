import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../shared/misc/hablar_exception_mapper.dart';
import '../bloc/hablar_dictionary_bloc.dart';
import '../widgets/dictionary_word_item.dart';

class HablarDictionaryContent extends StatelessWidget {
  // Only the first screenful enters one by one; words further down appear as they scroll in.
  static const int _staggeredItemCount = 12;

  const HablarDictionaryContent({super.key});

  @override
  Widget build(BuildContext context) {
    final HablarDictionaryBloc bloc = context.read<HablarDictionaryBloc>();
    final AppTranslations t = context.translations;
    final AppTextTheme texts = context.appTexts;
    final AppColorsTheme colors = context.appColors;

    return AppScaffold(
      onBack: () => bloc.add(const DictionaryBackPressed()),
      runningHead: t.hablar.title,
      body: BlocBuilder<HablarDictionaryBloc, HablarDictionaryState>(
        buildWhen: (HablarDictionaryState previous, HablarDictionaryState current) =>
            previous.isLoading != current.isLoading ||
            previous.dictionary != current.dictionary ||
            previous.error != current.error,
        builder: (BuildContext context, HablarDictionaryState state) {
          if (state.isLoading) return const AppLoadingPulse();

          final PersonalDictionary? dictionary = state.dictionary;
          final Exception? error = state.error;
          final String? message = switch (dictionary) {
            null => error == null ? t.hablar.errors.unknown : HablarExceptionMapper.map(error, t),
            PersonalDictionary(isComplete: true) => t.hablar.dictionary.complete(count: dictionary.words.length),
            PersonalDictionary(words: <LunfardoWord>[]) => t.hablar.dictionary.empty,
            _ => null,
          };

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.screenPadding,
                  AppDimens.gapXl,
                  AppDimens.screenPadding,
                  AppDimens.gapL,
                ),
                child: AppFadeIn(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppDimens.gapS,
                    children: <Widget>[
                      AppSectionTitle(text: t.hablar.entries.dictionary),
                      if (dictionary != null && dictionary.words.isNotEmpty)
                        AppText(
                          text: t.hablar.dictionary.wordCount(n: dictionary.words.length),
                          style: texts.captionSmall,
                          color: colors.textSecondary,
                        ),
                    ],
                  ),
                ),
              ),
              if (message != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenPadding),
                  child: AppFadeIn(
                    delay: AppMotions.staggerStep,
                    child: AppText(
                      text: message,
                      style: texts.quote,
                      maxLines: null,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              if (dictionary != null && dictionary.words.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenPadding),
                    itemCount: dictionary.words.length,
                    itemBuilder: (BuildContext context, int index) {
                      final LunfardoWord word = dictionary.words[index];
                      return AppFadeIn(
                        delay: index < _staggeredItemCount ? AppMotions.staggerStep * (index + 1) : Duration.zero,
                        child: DictionaryWordItem(
                          word: word.word,
                          meaning: word.meaning,
                          onPressed: () => bloc.add(WordPressed(word.id)),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
