part of 'leer_text_list_bloc.dart';

final class LeerTextListState {
  final bool isLoading;
  final List<TangoText> texts;
  final bool isNavigating;
  final Exception? error;

  const LeerTextListState({
    this.isLoading = true,
    this.texts = const <TangoText>[],
    this.isNavigating = false,
    this.error,
  });

  static const Object _unset = Object();

  LeerTextListState copyWith({
    bool? isLoading,
    List<TangoText>? texts,
    bool? isNavigating,
    Object? error = _unset,
  }) {
    return LeerTextListState(
      isLoading: isLoading ?? this.isLoading,
      texts: texts ?? this.texts,
      isNavigating: isNavigating ?? this.isNavigating,
      error: identical(error, _unset) ? this.error : error as Exception?,
    );
  }
}
