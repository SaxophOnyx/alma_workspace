part of 'hablar_word_card_bloc.dart';

final class HablarWordCardState {
  final bool isLoading;
  final LunfardoWord? word;
  final bool isInDictionary;
  final bool isAdding;
  final bool isNavigating;
  final Exception? error;

  const HablarWordCardState({
    this.isLoading = true,
    this.word,
    this.isInDictionary = false,
    this.isAdding = false,
    this.isNavigating = false,
    this.error,
  });

  static const Object _unset = Object();

  HablarWordCardState copyWith({
    bool? isLoading,
    Object? word = _unset,
    bool? isInDictionary,
    bool? isAdding,
    bool? isNavigating,
    Object? error = _unset,
  }) {
    return HablarWordCardState(
      isLoading: isLoading ?? this.isLoading,
      word: identical(word, _unset) ? this.word : word as LunfardoWord?,
      isInDictionary: isInDictionary ?? this.isInDictionary,
      isAdding: isAdding ?? this.isAdding,
      isNavigating: isNavigating ?? this.isNavigating,
      error: identical(error, _unset) ? this.error : error as Exception?,
    );
  }
}
