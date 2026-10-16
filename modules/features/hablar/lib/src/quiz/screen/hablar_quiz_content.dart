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

    return BlocBuilder<HablarQuizBloc, HablarQuizState>(
      buildWhen: (HablarQuizState previous, HablarQuizState current) =>
          previous.isLoading != current.isLoading ||
          previous.questions != current.questions ||
          previous.questionIndex != current.questionIndex ||
          previous.phase != current.phase ||
          previous.selectedIndex != current.selectedIndex ||
          previous.error != current.error,
      builder: (BuildContext context, HablarQuizState state) {
        final Exception? error = state.error;
        final QuizQuestion? question = state.question;
        final String? message = error != null
            ? HablarExceptionMapper.map(error, t)
            : (state.questions.isEmpty ? t.hablar.quiz.empty : null);
        final bool isAsking = !state.isLoading && message == null && question != null && state.phase != QuizPhase.result;

        return AppScaffold(
          onBack: () => bloc.add(const QuizBackPressed()),
          runningHead: isAsking
              ? t.hablar.quiz.progress(current: state.questionIndex + 1, total: state.questions.length)
              : t.hablar.title,
          body: _QuizBody(state: state, question: question, message: message),
        );
      },
    );
  }
}

class _QuizBody extends StatelessWidget {
  final HablarQuizState state;
  final QuizQuestion? question;
  final String? message;

  const _QuizBody({
    required this.state,
    required this.question,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) return const AppLoadingPulse();

    final HablarQuizBloc bloc = context.read<HablarQuizBloc>();
    final AppTranslations t = context.translations;
    final QuizQuestion? question = this.question;
    final String? message = this.message;

    final Widget child;
    if (message != null) {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AppText(
            text: message,
            style: context.appTexts.quote,
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
        selectedIndex: state.phase == QuizPhase.answered ? state.selectedIndex : null,
        onOptionSelected: (int index) => bloc.add(OptionSelected(index)),
      );
    }

    // The echo is the question still on screen, so it must not fade the question in again.
    final QuizPhase screen = state.phase == QuizPhase.answered ? QuizPhase.question : state.phase;
    final bool isExplaining = message == null && state.phase == QuizPhase.explanation;
    return GestureDetector(
      // The whole screen dismisses the explanation, not just its text.
      behavior: HitTestBehavior.opaque,
      onTap: isExplaining ? () => bloc.add(const ExplanationDismissed()) : null,
      child: AppFadeIn(
        key: ValueKey<(int, QuizPhase)>((state.questionIndex, screen)),
        duration: AppMotions.durationShort,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.screenPadding),
            child: child,
          ),
        ),
      ),
    );
  }
}
