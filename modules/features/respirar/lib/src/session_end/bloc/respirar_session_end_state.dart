part of 'respirar_session_end_bloc.dart';

final class RespirarSessionEndState {
  final bool isLoading;
  final Quote? quote;
  final bool isNavigating;
  final Exception? error;

  const RespirarSessionEndState({
    this.isLoading = true,
    this.quote,
    this.isNavigating = false,
    this.error,
  });

  static const Object _unset = Object();

  RespirarSessionEndState copyWith({
    bool? isLoading,
    Object? quote = _unset,
    bool? isNavigating,
    Object? error = _unset,
  }) {
    return RespirarSessionEndState(
      isLoading: isLoading ?? this.isLoading,
      quote: identical(quote, _unset) ? this.quote : quote as Quote?,
      isNavigating: isNavigating ?? this.isNavigating,
      error: identical(error, _unset) ? this.error : error as Exception?,
    );
  }
}
