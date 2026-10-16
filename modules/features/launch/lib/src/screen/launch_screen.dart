import 'package:auto_route/auto_route.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../bloc/launch_bloc.dart';
import '../navigation/launch_navigator.dart';
import 'launch_content.dart';

@RoutePage()
class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LaunchBloc>(
      // LaunchContent never reads the bloc, so it must be created eagerly to start the check.
      lazy: false,
      create:(BuildContext context) {
        return LaunchBloc(
          getOnboardingCompletedUseCase: context.resolve<GetOnboardingCompletedUseCase>(),
          navigator: context.resolve<LaunchNavigator>(),
        )..add(const LaunchStarted());
      },
      child: const LaunchContent(),
    );
  }
}
