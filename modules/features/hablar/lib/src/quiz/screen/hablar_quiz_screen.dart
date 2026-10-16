import 'package:auto_route/auto_route.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../navigation/hablar_navigator.dart';
import '../bloc/hablar_quiz_bloc.dart';
import 'hablar_quiz_content.dart';

@RoutePage()
class HablarQuizScreen extends StatelessWidget {
  const HablarQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HablarQuizBloc>(
      create: (BuildContext context) {
        return HablarQuizBloc(
          createQuizUseCase: context.resolve<CreateQuizUseCase>(),
          navigator: context.resolve<HablarNavigator>(),
        )..add(const QuizStarted());
      },
      child: const HablarQuizContent(),
    );
  }
}
