import 'package:auto_route/auto_route.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../navigation/leer_navigator.dart';
import '../bloc/leer_context_bloc.dart';
import 'leer_context_content.dart';

@RoutePage()
class LeerContextScreen extends StatelessWidget {
  final String textId;

  const LeerContextScreen({
    super.key,
    required this.textId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LeerContextBloc>(
      create: (BuildContext context) {
        return LeerContextBloc(
          textId: textId,
          getTextUseCase: context.resolve<GetTextUseCase>(),
          navigator: context.resolve<LeerNavigator>(),
        )..add(const ContextStarted());
      },
      child: const LeerContextContent(),
    );
  }
}
