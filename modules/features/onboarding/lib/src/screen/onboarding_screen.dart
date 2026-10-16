import 'package:auto_route/auto_route.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../bloc/onboarding_bloc.dart';
import '../navigation/onboarding_navigator.dart';
import 'onboarding_content.dart';

@RoutePage()
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingBloc>(
      create: (BuildContext context) {
        return OnboardingBloc(
          completeOnboardingUseCase: context.resolve<CompleteOnboardingUseCase>(),
          navigator: context.resolve<OnboardingNavigator>(),
        );
      },
      child: const OnboardingContent(),
    );
  }
}
