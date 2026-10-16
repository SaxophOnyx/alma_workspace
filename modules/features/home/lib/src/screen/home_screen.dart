import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../bloc/home_bloc.dart';
import '../navigation/home_navigator.dart';
import 'home_content.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (BuildContext context) {
        return HomeBloc(
          navigator: context.resolve<HomeNavigator>(),
        );
      },
      child: const HomeContent(),
    );
  }
}
