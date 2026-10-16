part of 'leer_context_bloc.dart';

final class LeerContextState {
  final bool isLoading;
  final TangoText? text;
  final bool isNavigating;
  final Exception? error;

  const LeerContextState({
    this.isLoading = true,
    this.text,
    this.isNavigating = false,
    this.error,
  });

  static const Object _unset = Object();

  LeerContextState copyWith({
    bool? isLoading,
    Object? text = _unset,
    bool? isNavigating,
    Object? error = _unset,
  }) {
    return LeerContextState(
      isLoading: isLoading ?? this.isLoading,
      text: identical(text, _unset) ? this.text : text as TangoText?,
      isNavigating: isNavigating ?? this.isNavigating,
      error: identical(error, _unset) ? this.error : error as Exception?,
    );
  }
}
