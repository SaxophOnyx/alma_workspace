part of 'hablar_dictionary_bloc.dart';

final class HablarDictionaryState {
  final bool isLoading;
  final PersonalDictionary? dictionary;
  final bool isNavigating;
  final Exception? error;

  const HablarDictionaryState({
    this.isLoading = true,
    this.dictionary,
    this.isNavigating = false,
    this.error,
  });

  static const Object _unset = Object();

  HablarDictionaryState copyWith({
    bool? isLoading,
    Object? dictionary = _unset,
    bool? isNavigating,
    Object? error = _unset,
  }) {
    return HablarDictionaryState(
      isLoading: isLoading ?? this.isLoading,
      dictionary: identical(dictionary, _unset) ? this.dictionary : dictionary as PersonalDictionary?,
      isNavigating: isNavigating ?? this.isNavigating,
      error: identical(error, _unset) ? this.error : error as Exception?,
    );
  }
}
