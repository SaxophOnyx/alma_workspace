part of 'hablar_main_bloc.dart';

final class HablarMainState {
  /// Words in the personal dictionary; `null` until loaded or when the dictionary cannot be read.
  final int? dictionaryCount;
  final bool isNavigating;

  const HablarMainState({
    this.dictionaryCount,
    this.isNavigating = false,
  });

  static const Object _unset = Object();

  HablarMainState copyWith({
    Object? dictionaryCount = _unset,
    bool? isNavigating,
  }) {
    return HablarMainState(
      dictionaryCount: identical(dictionaryCount, _unset) ? this.dictionaryCount : dictionaryCount as int?,
      isNavigating: isNavigating ?? this.isNavigating,
    );
  }
}
