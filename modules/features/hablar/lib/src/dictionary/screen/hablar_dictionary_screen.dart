import 'package:auto_route/auto_route.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../navigation/hablar_navigator.dart';
import '../bloc/hablar_dictionary_bloc.dart';
import 'hablar_dictionary_content.dart';

@RoutePage()
class HablarDictionaryScreen extends StatelessWidget {
  const HablarDictionaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HablarDictionaryBloc>(
      create: (BuildContext context) {
        return HablarDictionaryBloc(
          getPersonalDictionaryUseCase: context.resolve<GetPersonalDictionaryUseCase>(),
          navigator: context.resolve<HablarNavigator>(),
        )..add(const DictionaryStarted());
      },
      child: const HablarDictionaryContent(),
    );
  }
}
