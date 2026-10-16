import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class QuizResult extends StatelessWidget {
  final int correctCount;
  final int questionCount;
  final VoidCallback onTryAgainPressed;
  final VoidCallback onBackToHablarPressed;

  const QuizResult({
    super.key,
    required this.correctCount,
    required this.questionCount,
    required this.onTryAgainPressed,
    required this.onBackToHablarPressed,
  });

  @override
  Widget build(BuildContext context) {
    final AppTranslations t = context.translations;

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: AppDimens.gapS,
      children: <Widget>[
        AppText(
          text: t.hablar.quiz.result(correct: correctCount, total: questionCount),
          style: context.appTexts.poetry,
          maxLines: null,
          textAlign: TextAlign.center,
          color: context.appColors.textPrimary,
        ),
        const SizedBox(height: AppDimens.gapL),
        AppTextButton(
          text: t.hablar.quiz.tryAgain,
          onPressed: onTryAgainPressed,
        ),
        AppTextButton(
          text: t.hablar.quiz.backToHablar,
          onPressed: onBackToHablarPressed,
          style: AppTextButtonStyle.quiet,
        ),
      ],
    );
  }
}
