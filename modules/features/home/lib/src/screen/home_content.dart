import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../bloc/home_bloc.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.translations.home.title),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (BuildContext context, HomeState state) {
          return Center(
            child: Text(context.translations.home.subtitle),
          );
        },
      ),
    );
  }
}
