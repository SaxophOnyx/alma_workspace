import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../shared/widgets/etymology_chain.dart';
import '../../shared/widgets/example_line.dart';

class WordCard extends StatelessWidget {
  final LunfardoWord word;
  final bool isInDictionary;
  final bool isAdding;
  final String? errorText;
  final VoidCallback onAddPressed;
  final VoidCallback onOpenTextPressed;

  const WordCard({
    super.key,
    required this.word,
    required this.isInDictionary,
    required this.isAdding,
    required this.errorText,
    required this.onAddPressed,
    required this.onOpenTextPressed,
  });

  @override
  Widget build(BuildContext context) {
    final AppTranslations t = context.translations;
    final AppTextTheme texts = context.appTexts;
    final AppColorsTheme colors = context.appColors;
    final String? errorText = this.errorText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppText(
          text: word.word,
          style: texts.title,
          maxLines: null,
          color: colors.accent,
        ),
        const SizedBox(height: AppDimens.gapXs),
        AppText(
          text: word.pronunciation,
          style: texts.captionSmall,
          color: colors.textSecondary,
        ),
        const SizedBox(height: AppDimens.gapL),
        AppText(
          text: word.meaning,
          style: texts.body,
          maxLines: null,
          color: colors.textPrimary,
        ),
        const SizedBox(height: AppDimens.gapL),
        AppText(
          text: t.hablar.card.etymology,
          style: texts.caption,
          color: colors.textSecondary,
        ),
        const SizedBox(height: AppDimens.gapXs),
        EtymologyChain(steps: word.etymology),
        const SizedBox(height: AppDimens.gapL),
        AppText(
          text: t.hablar.card.example,
          style: texts.caption,
          color: colors.textSecondary,
        ),
        const SizedBox(height: AppDimens.gapS),
        ExampleLine(line: word.example.line, wordId: word.id),
        const SizedBox(height: AppDimens.gapXs),
        AppText(
          text: t.hablar.card.source(title: word.example.title, year: word.example.year),
          style: texts.captionSmall,
          color: colors.textSecondary,
        ),
        AppTextButton(
          text: t.hablar.card.openText,
          onPressed: onOpenTextPressed,
        ),
        if (word.related.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppDimens.gapM),
          AppText(
            text: t.hablar.card.related(words: word.related.join(t.hablar.card.relatedSeparator)),
            style: texts.caption,
            maxLines: null,
            color: colors.textSecondary,
          ),
        ],
        const SizedBox(height: AppDimens.gapL),
        AppTextButton(
          text: isInDictionary ? t.hablar.card.inDictionary : t.hablar.card.add,
          onPressed: onAddPressed,
          isEnabled: !isInDictionary && !isAdding,
        ),
        if (errorText != null)
          AppText(
            text: errorText,
            style: texts.captionSmall,
            maxLines: null,
            color: colors.textSecondary,
          ),
      ],
    );
  }
}
