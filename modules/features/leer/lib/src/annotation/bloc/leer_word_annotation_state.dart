part of 'leer_word_annotation_bloc.dart';

final class LeerWordAnnotationState {
  final bool isLoading;
  final LunfardoWord? word;
  final bool isInDictionary;
  final bool isAdding;
  final bool isClosing;
  final Exception? error;

  const LeerWordAnnotationState({
    this.isLoading = true,
    this.word,
    this.isInDictionary = false,
    this.isAdding = false,
    this.isClosing = false,
    this.error,
  });

  static const Object _unset = Object();

  LeerWordAnnotationState copyWith({
    bool? isLoading,
    Object? word = _unset,
    bool? isInDictionary,
    bool? isAdding,
    bool? isClosing,
    Object? error = _unset,
  }) {
    return LeerWordAnnotationState(
      isLoading: isLoading ?? this.isLoading,
      word: identical(word, _unset) ? this.word : word as LunfardoWord?,
      isInDictionary: isInDictionary ?? this.isInDictionary,
      isAdding: isAdding ?? this.isAdding,
      isClosing: isClosing ?? this.isClosing,
      error: identical(error, _unset) ? this.error : error as Exception?,
    );
  }
}
