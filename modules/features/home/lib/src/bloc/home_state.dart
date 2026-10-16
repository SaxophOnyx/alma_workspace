part of 'home_bloc.dart';

final class HomeState {
  final HomeEntry? highlightedEntry;
  final bool isNavigating;

  const HomeState({
    this.highlightedEntry,
    this.isNavigating = false,
  });

  static const Object _unset = Object();

  HomeState copyWith({
    Object? highlightedEntry = _unset,
    bool? isNavigating,
  }) {
    return HomeState(
      highlightedEntry: identical(highlightedEntry, _unset) ? this.highlightedEntry : highlightedEntry as HomeEntry?,
      isNavigating: isNavigating ?? this.isNavigating,
    );
  }
}
