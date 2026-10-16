import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../shared/widgets/etymology_chain.dart';
import '../../shared/widgets/example_line.dart';

/// What the word means and where it comes from; deliberately says nothing about the answer given.
class QuizExplanation extends StatelessWidget {
  final QuizQuestion question;

  const QuizExplanation({
    super.key,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    final AppTextTheme texts = context.appTexts;
    final AppColorsTheme colors = context.appColors;
    final LunfardoWord word = question.word;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppText(
          text: word.word,
          style: texts.wordHeadline,
          maxLines: null,
          color: colors.accent,
        ),
        const SizedBox(height: AppDimens.gapS),
        AppText(
          text: word.meaning,
          style: texts.bodyLarge,
          maxLines: null,
          color: colors.textPrimary,
        ),
        const SizedBox(height: AppDimens.gapL),
        if (question.type == QuizQuestionType.example)
          ExampleLine(line: word.example.line, wordId: word.id)
        else
          EtymologyChain(steps: word.etymology),
        const SizedBox(height: AppDimens.gapXxl),
        AppFadeIn(
          delay: AppMotions.durationLong,
          child: AppText(
            text: context.translations.hablar.quiz.continueHint,
            style: texts.smallCaps,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
