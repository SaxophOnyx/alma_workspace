import 'package:auto_route/auto_route.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../navigation/respirar_navigator.dart';
import '../bloc/respirar_session_end_bloc.dart';
import 'respirar_session_end_content.dart';

@RoutePage()
class RespirarSessionEndScreen extends StatelessWidget {
  const RespirarSessionEndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RespirarSessionEndBloc>(
      create: (BuildContext context) {
        return RespirarSessionEndBloc(
          getRandomQuoteUseCase: context.resolve<GetRandomQuoteUseCase>(),
          navigator: context.resolve<RespirarNavigator>(),
        )..add(const SessionEndStarted());
      },
      child: const RespirarSessionEndContent(),
    );
  }
}
