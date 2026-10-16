import 'package:auto_route/auto_route.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../navigation/leer_navigator.dart';
import '../bloc/leer_reading_bloc.dart';
import 'leer_reading_content.dart';

@RoutePage()
class LeerReadingScreen extends StatelessWidget {
  final String textId;

  const LeerReadingScreen({
    super.key,
    required this.textId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LeerReadingBloc>(
      create: (BuildContext context) {
        return LeerReadingBloc(
          textId: textId,
          getTextUseCase: context.resolve<GetTextUseCase>(),
          markWordEncounteredUseCase: context.resolve<MarkWordEncounteredUseCase>(),
          navigator: context.resolve<LeerNavigator>(),
        )..add(const ReadingStarted());
      },
      child: const LeerReadingContent(),
    );
  }
}
