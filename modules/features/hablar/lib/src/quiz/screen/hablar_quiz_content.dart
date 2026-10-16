import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../shared/misc/hablar_exception_mapper.dart';
import '../bloc/hablar_quiz_bloc.dart';
import '../misc/quiz_phase.dart';
import '../widgets/quiz_explanation.dart';
import '../widgets/quiz_question_view.dart';
import '../widgets/quiz_result.dart';

class HablarQuizContent extends StatelessWidget {
  const HablarQuizContent({super.key});

  @override
  Widget build(BuildContext context) {
    final HablarQuizBloc bloc = context.read<HablarQuizBloc>();
    final AppTranslations t = context.translations;

    return AppScaffold(
      onBack: () => bloc.add(const QuizBackPressed()),
      body: BlocBuilder<HablarQuizBloc, HablarQuizState>(
        buildWhen: (HablarQuizState previous, HablarQuizState current) =>
            previous.isLoading != current.isLoading ||
            previous.questions != current.questions ||
            previous.questionIndex != current.questionIndex ||
            previous.phase != current.phase ||
            previous.error != current.error,
        builder: (BuildContext context, HablarQuizState state) {
          if (state.isLoading) return const SizedBox.shrink();

          final Exception? error = state.error;
          final QuizQuestion? question = state.question;
          final String? message = error != null
              ? HablarExceptionMapper.map(error, t)
              : (state.questions.isEmpty ? t.hablar.quiz.empty : null);

          final Widget child;
          if (message != null) {
            child = Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AppText(
                  text: message,
                  style: context.appTexts.body,
                  maxLines: null,
                  textAlign: TextAlign.center,
                  color: context.appColors.textSecondary,
                ),
                const SizedBox(height: AppDimens.gapL),
                AppTextButton(
                  text: t.hablar.quiz.backToHablar,
                  onPressed: () => bloc.add(const BackToHablarPressed()),
                ),
              ],
            );
          } else if (state.phase == QuizPhase.result || question == null) {
            child = QuizResult(
              correctCount: state.correctCount,
              questionCount: state.questions.length,
              onTryAgainPressed: () => bloc.add(const TryAgainPressed()),
              onBackToHablarPressed: () => bloc.add(const BackToHablarPressed()),
            );
          } else if (state.phase == QuizPhase.explanation) {
            child = QuizExplanation(question: question);
          } else {
            child = QuizQuestionView(
              question: question,
              onOptionSelected: (int index) => bloc.add(OptionSelected(index)),
            );
          }

          final bool isExplaining = message == null && state.phase == QuizPhase.explanation;
          return GestureDetector(
            // The whole screen dismisses the explanation, not just its text.
            behavior: HitTestBehavior.opaque,
            onTap: isExplaining ? () => bloc.add(const ExplanationDismissed()) : null,
            child: AppFadeIn(
              key: ValueKey<(int, QuizPhase)>((state.questionIndex, state.phase)),
              duration: AppMotions.durationShort,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimens.screenPadding),
                  child: child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
