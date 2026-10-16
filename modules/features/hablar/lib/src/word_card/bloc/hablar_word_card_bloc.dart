import 'package:domain/domain.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../navigation/hablar_navigator.dart';

part 'hablar_word_card_event.dart';
part 'hablar_word_card_state.dart';

class HablarWordCardBloc extends Bloc<HablarWordCardEvent, HablarWordCardState> {
  /// The word to show; `null` shows the word of the day.
  final String? _wordId;
  final GetWordOfTheDayUseCase _getWordOfTheDayUseCase;
  final GetLunfardoWordUseCase _getLunfardoWordUseCase;
  final IsWordInDictionaryUseCase _isWordInDictionaryUseCase;
  final AddWordToDictionaryUseCase _addWordToDictionaryUseCase;
  final MarkWordEncounteredUseCase _markWordEncounteredUseCase;
  final HablarNavigator _navigator;

  HablarWordCardBloc({
    required String? wordId,
    required GetWordOfTheDayUseCase getWordOfTheDayUseCase,
    required GetLunfardoWordUseCase getLunfardoWordUseCase,
    required IsWordInDictionaryUseCase isWordInDictionaryUseCase,
    required AddWordToDictionaryUseCase addWordToDictionaryUseCase,
    required MarkWordEncounteredUseCase markWordEncounteredUseCase,
    required HablarNavigator navigator,
  }) : _wordId = wordId,
       _getWordOfTheDayUseCase = getWordOfTheDayUseCase,
       _getLunfardoWordUseCase = getLunfardoWordUseCase,
       _isWordInDictionaryUseCase = isWordInDictionaryUseCase,
       _addWordToDictionaryUseCase = addWordToDictionaryUseCase,
       _markWordEncounteredUseCase = markWordEncounteredUseCase,
       _navigator = navigator,
       super(const HablarWordCardState()) {
    on<WordCardStarted>(_onStarted);
    on<AddPressed>(_onAddPressed);
    on<OpenTextPressed>(_onOpenTextPressed);
    on<WordCardBackPressed>(_onBackPressed);
  }

  Future<void> _onStarted(WordCardStarted event, Emitter<HablarWordCardState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));

    final LunfardoWord word;
    try {
      final String? wordId = _wordId;
      word = wordId == null
          ? await _getWordOfTheDayUseCase.execute(const NoParams())
          : await _getLunfardoWordUseCase.execute(GetLunfardoWordParams(wordId: wordId));
    } on Exception catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, word: null, error: e));
      return;
    }
    if (isClosed) return;

    try {
      await _markWordEncounteredUseCase.execute(MarkWordEncounteredParams(wordId: word.id));
    } on Exception catch (_) {
      // Best effort: a missed encounter only narrows the quiz pool.
    }
    if (isClosed) return;

    try {
      final bool isInDictionary = await _isWordInDictionaryUseCase.execute(IsWordInDictionaryParams(wordId: word.id));
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, word: word, isInDictionary: isInDictionary));
    } on Exception catch (e) {
      // The word is still worth showing when the dictionary cannot be read.
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, word: word, isInDictionary: false, error: e));
    }
  }

  Future<void> _onAddPressed(AddPressed event, Emitter<HablarWordCardState> emit) async {
    final LunfardoWord? word = state.word;
    if (word == null || state.isInDictionary || state.isAdding) return;
    emit(state.copyWith(isAdding: true, error: null));

    try {
      await _addWordToDictionaryUseCase.execute(AddWordToDictionaryParams(wordId: word.id));
      if (isClosed) return;
      emit(state.copyWith(isAdding: false, isInDictionary: true));
    } on Exception catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isAdding: false, error: e));
    }
  }

  Future<void> _onOpenTextPressed(OpenTextPressed event, Emitter<HablarWordCardState> emit) async {
    final LunfardoWord? word = state.word;
    if (word == null || state.isNavigating) return;
    emit(state.copyWith(isNavigating: true));

    try {
      await _navigator.openText(word.example.textId);
    } on Exception catch (_) {
      // Stay usable; the user can tap again.
    }
    if (isClosed) return;

    emit(state.copyWith(isNavigating: false));
  }

  Future<void> _onBackPressed(WordCardBackPressed event, Emitter<HablarWordCardState> emit) async {
    if (state.isNavigating) return;
    await _navigator.back();
  }
}
