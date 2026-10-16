import 'package:shared_ui/shared_ui.dart';

import '../navigation/home_navigator.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  // ignore: unused_field - kept only to demonstrate the navigator pattern; remove once used.
  final HomeNavigator _navigator;

  HomeBloc({
    required HomeNavigator navigator,
  }) : _navigator = navigator,
       super(const HomeState.initial());
}
