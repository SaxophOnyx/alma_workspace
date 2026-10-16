import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../shared/widgets/example_line.dart';

class QuizQuestionView extends StatelessWidget {
  final QuizQuestion question;

  /// The option chosen for this question, echoed for a moment before the explanation.
  final int? selectedIndex;
  final ValueChanged<int> onOptionSelected;

  const QuizQuestionView({
    super.key,
    required this.question,
    required this.selectedIndex,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final AppTranslations t = context.translations;
    final AppTextTheme texts = context.appTexts;
    final AppColorsTheme colors = context.appColors;
    final LunfardoWord word = question.word;
    final int? selectedIndex = this.selectedIndex;

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
          style: texts.menu,
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
        IgnorePointer(
          ignoring: selectedIndex != null,
          child: Column(
            spacing: AppDimens.gapXs,
            children: <Widget>[
              for (int i = 0; i < question.options.length; i++)
                AppFadeIn(
                  delay: AppMotions.staggerStep * (i + 1),
                  child: _QuizOption(
                    text: question.options[i],
                    echo: switch (selectedIndex) {
                      null => _OptionEcho.none,
                      _ when question.isCorrect(i) => _OptionEcho.right,
                      _ when i == selectedIndex => _OptionEcho.wrong,
                      _ => _OptionEcho.faded,
                    },
                    onPressed: () => onOptionSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _OptionEcho {
  none,
  right,
  wrong,
  faded,
}

/// One answer; once an answer is chosen the right one turns Oro, a wrong choice gets a Carmín line.
class _QuizOption extends StatelessWidget {
  static const double _fadedOpacity = 0.25;

  final String text;
  final _OptionEcho echo;
  final VoidCallback onPressed;

  const _QuizOption({
    required this.text,
    required this.echo,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final AppColorsTheme colors = context.appColors;

    return AnimatedOpacity(
      opacity: echo == _OptionEcho.faded ? _fadedOpacity : 1,
      duration: AppMotions.durationShort,
      curve: AppMotions.standard,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AppTextButton(
            text: text,
            onPressed: onPressed,
            style: AppTextButtonStyle.menu,
            isHighlighted: echo == _OptionEcho.right,
          ),
          AnimatedContainer(
            duration: AppMotions.durationShort,
            curve: AppMotions.entrance,
            width: echo == _OptionEcho.wrong ? AppDimens.ruleWidth : 0,
            height: AppDimens.ruleThickness,
            color: colors.signal,
          ),
        ],
      ),
    );
  }
}
