part of 'launch_bloc.dart';

sealed class LaunchEvent {
  const LaunchEvent();
}

final class LaunchStarted extends LaunchEvent {
  const LaunchStarted();
}
