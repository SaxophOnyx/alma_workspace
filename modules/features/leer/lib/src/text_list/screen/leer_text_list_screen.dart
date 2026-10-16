import 'package:auto_route/auto_route.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../navigation/leer_navigator.dart';
import '../bloc/leer_text_list_bloc.dart';
import 'leer_text_list_content.dart';

@RoutePage()
class LeerTextListScreen extends StatelessWidget {
  const LeerTextListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LeerTextListBloc>(
      create: (BuildContext context) {
        return LeerTextListBloc(
          getTextsUseCase: context.resolve<GetTextsUseCase>(),
          navigator: context.resolve<LeerNavigator>(),
        )..add(const TextListStarted());
      },
      child: const LeerTextListContent(),
    );
  }
}
