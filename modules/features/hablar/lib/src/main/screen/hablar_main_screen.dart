import 'package:auto_route/auto_route.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../navigation/hablar_navigator.dart';
import '../bloc/hablar_main_bloc.dart';
import 'hablar_main_content.dart';

@RoutePage()
class HablarMainScreen extends StatelessWidget {
  const HablarMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HablarMainBloc>(
      create: (BuildContext context) {
        return HablarMainBloc(
          getPersonalDictionaryUseCase: context.resolve<GetPersonalDictionaryUseCase>(),
          navigator: context.resolve<HablarNavigator>(),
        )..add(const HablarStarted());
      },
      child: const HablarMainContent(),
    );
  }
}
