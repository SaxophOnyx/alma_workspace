import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../navigation/respirar_navigator.dart';
import '../bloc/respirar_leave_confirmation_bloc.dart';
import 'respirar_leave_confirmation_content.dart';

@RoutePage()
class RespirarLeaveConfirmationScreen extends StatelessWidget {
  const RespirarLeaveConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RespirarLeaveConfirmationBloc>(
      create: (BuildContext context) {
        return RespirarLeaveConfirmationBloc(
          navigator: context.resolve<RespirarNavigator>(),
        );
      },
      child: const RespirarLeaveConfirmationContent(),
    );
  }
}
