import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../shared/misc/hablar_exception_mapper.dart';
import '../bloc/hablar_dictionary_bloc.dart';
import '../widgets/dictionary_word_item.dart';

class HablarDictionaryContent extends StatelessWidget {
  const HablarDictionaryContent({super.key});

  @override
  Widget build(BuildContext context) {
    final HablarDictionaryBloc bloc = context.read<HablarDictionaryBloc>();
    final AppTranslations t = context.translations;
    final AppTextTheme texts = context.appTexts;
    final AppColorsTheme colors = context.appColors;

    return AppScaffold(
      onBack: () => bloc.add(const DictionaryBackPressed()),
      body: BlocBuilder<HablarDictionaryBloc, HablarDictionaryState>(
        buildWhen: (HablarDictionaryState previous, HablarDictionaryState current) =>
            previous.isLoading != current.isLoading ||
            previous.dictionary != current.dictionary ||
            previous.error != current.error,
        builder: (BuildContext context, HablarDictionaryState state) {
          if (state.isLoading) return const SizedBox.shrink();

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
                padding: const EdgeInsets.all(AppDimens.screenPadding),
                child: AppText(
                  text: dictionary == null
                      ? t.hablar.entries.dictionary
                      : t.hablar.entries.dictionaryWithCount(count: dictionary.words.length),
                  style: texts.title,
                  maxLines: null,
                ),
              ),
              if (message != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenPadding),
                  child: AppText(
                    text: message,
                    style: texts.body,
                    maxLines: null,
                    color: colors.textSecondary,
                  ),
                ),
              if (dictionary != null && dictionary.words.isNotEmpty)
                Expanded(
                  child: AppFadeIn(
                    duration: AppMotions.durationMedium,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppDimens.screenPadding),
                      itemCount: dictionary.words.length,
                      itemBuilder: (BuildContext context, int index) {
                        final LunfardoWord word = dictionary.words[index];
                        return DictionaryWordItem(
                          word: word.word,
                          onPressed: () => bloc.add(WordPressed(word.id)),
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
