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

    final List<Widget> sections = <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppText(
            text: word.word,
            style: texts.display,
            maxLines: null,
            color: colors.accent,
          ),
          _CollectedRule(isCollected: isInDictionary),
          const SizedBox(height: AppDimens.gapS),
          AppText(
            text: word.pronunciation,
            style: texts.captionSmall,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppDimens.gapL),
          AppText(
            text: word.meaning,
            style: texts.bodyLarge,
            maxLines: null,
            color: colors.textPrimary,
          ),
        ],
      ),
      _Section(
        label: t.hablar.card.etymology,
        child: EtymologyChain(steps: word.etymology),
      ),
      _Section(
        label: t.hablar.card.example,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppDimens.gapXs,
          children: <Widget>[
            ExampleLine(line: word.example.line, wordId: word.id),
            AppText(
              text: t.hablar.card.source(title: word.example.title, year: word.example.year),
              style: texts.captionSmall,
              color: colors.textSecondary,
            ),
            AppTextButton(
              text: t.hablar.card.openText,
              onPressed: onOpenTextPressed,
            ),
          ],
        ),
      ),
      if (word.related.isNotEmpty)
        AppText(
          text: t.hablar.card.related(words: word.related.join(t.hablar.card.relatedSeparator)),
          style: texts.caption,
          maxLines: null,
          color: colors.textSecondary,
        ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppDimens.gapXl,
      children: <Widget>[
        for (int i = 0; i < sections.length; i++)
          AppFadeIn(
            delay: AppMotions.staggerStep * i,
            child: sections[i],
          ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  final Widget child;

  const _Section({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppDimens.gapS,
      children: <Widget>[
        AppText(
          text: label,
          style: context.appTexts.smallCaps,
          color: context.appColors.textSecondary,
        ),
        child,
      ],
    );
  }
}

/// An Oro line that draws itself under the word once it is in the dictionary.
class _CollectedRule extends StatelessWidget {
  final bool isCollected;

  const _CollectedRule({
    required this.isCollected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotions.durationShort,
      curve: AppMotions.entrance,
      width: isCollected ? AppDimens.ruleWidth : 0,
      height: AppDimens.ruleThickness,
      color: context.appColors.accent,
    );
  }
}
