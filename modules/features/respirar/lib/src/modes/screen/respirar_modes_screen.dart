import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../navigation/respirar_navigator.dart';
import '../bloc/respirar_modes_bloc.dart';
import 'respirar_modes_content.dart';

@RoutePage()
class RespirarModesScreen extends StatelessWidget {
  const RespirarModesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RespirarModesBloc>(
      create: (BuildContext context) {
        return RespirarModesBloc(
          navigator: context.resolve<RespirarNavigator>(),
        );
      },
      child: const RespirarModesContent(),
    );
  }
}
