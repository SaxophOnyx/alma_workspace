import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../shared/widgets/example_line.dart';

class QuizQuestionView extends StatelessWidget {
  final QuizQuestion question;
  final ValueChanged<int> onOptionSelected;

  const QuizQuestionView({
    super.key,
    required this.question,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final AppTranslations t = context.translations;
    final AppTextTheme texts = context.appTexts;
    final AppColorsTheme colors = context.appColors;
    final LunfardoWord word = question.word;

    final String prompt = switch (question.type) {
      QuizQuestionType.meaning => t.hablar.quiz.meaningPrompt(word: word.word),
      QuizQuestionType.word => t.hablar.quiz.wordPrompt,
      QuizQuestionType.etymology => t.hablar.quiz.etymologyPrompt,
      QuizQuestionType.example => t.hablar.quiz.examplePrompt,
      QuizQuestionType.related => t.hablar.quiz.relatedPrompt(related: question.relatedClue),
    };
    final String? clue = switch (question.type) {
      QuizQuestionType.word => word.meaning,
      QuizQuestionType.etymology => word.etymology.first,
      QuizQuestionType.meaning || QuizQuestionType.example || QuizQuestionType.related => null,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppText(
          text: prompt,
          style: texts.listTitle,
          maxLines: null,
          textAlign: TextAlign.center,
          color: colors.textPrimary,
        ),
        if (clue != null) ...<Widget>[
          const SizedBox(height: AppDimens.gapM),
          AppText(
            text: clue,
            style: texts.quote,
            maxLines: null,
            textAlign: TextAlign.center,
            color: colors.textSecondary,
          ),
        ],
        if (question.type == QuizQuestionType.example) ...<Widget>[
          const SizedBox(height: AppDimens.gapM),
          Center(
            child: ExampleLine(line: word.example.line, wordId: word.id, blank: t.hablar.quiz.blank),
          ),
        ],
        const SizedBox(height: AppDimens.gapXl),
        for (int i = 0; i < question.options.length; i++)
          AppTextButton(
            text: question.options[i],
            onPressed: () => onOptionSelected(i),
          ),
      ],
    );
  }
}
