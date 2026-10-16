import 'package:domain/domain.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../navigation/leer_navigator.dart';

part 'leer_word_annotation_event.dart';
part 'leer_word_annotation_state.dart';

class LeerWordAnnotationBloc extends Bloc<LeerWordAnnotationEvent, LeerWordAnnotationState> {
  final String _wordId;
  final GetLunfardoWordUseCase _getLunfardoWordUseCase;
  final IsWordInDictionaryUseCase _isWordInDictionaryUseCase;
  final AddWordToDictionaryUseCase _addWordToDictionaryUseCase;
  final LeerNavigator _navigator;

  LeerWordAnnotationBloc({
    required String wordId,
    required GetLunfardoWordUseCase getLunfardoWordUseCase,
    required IsWordInDictionaryUseCase isWordInDictionaryUseCase,
    required AddWordToDictionaryUseCase addWordToDictionaryUseCase,
    required LeerNavigator navigator,
  }) : _wordId = wordId,
       _getLunfardoWordUseCase = getLunfardoWordUseCase,
       _isWordInDictionaryUseCase = isWordInDictionaryUseCase,
       _addWordToDictionaryUseCase = addWordToDictionaryUseCase,
       _navigator = navigator,
       super(const LeerWordAnnotationState()) {
    on<AnnotationStarted>(_onStarted);
    on<AddPressed>(_onAddPressed);
    on<ClosePressed>(_onClosePressed);
  }

  Future<void> _onStarted(AnnotationStarted event, Emitter<LeerWordAnnotationState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));

    final LunfardoWord word;
    try {
      word = await _getLunfardoWordUseCase.execute(GetLunfardoWordParams(wordId: _wordId));
    } on Exception catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, word: null, error: e));
      return;
    }
    if (isClosed) return;

    try {
      final bool isInDictionary = await _isWordInDictionaryUseCase.execute(IsWordInDictionaryParams(wordId: _wordId));
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, word: word, isInDictionary: isInDictionary));
    } on Exception catch (e) {
      // The word is still worth showing when the dictionary cannot be read.
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, word: word, isInDictionary: false, error: e));
    }
  }

  Future<void> _onAddPressed(AddPressed event, Emitter<LeerWordAnnotationState> emit) async {
    if (state.word == null || state.isInDictionary || state.isAdding) return;
    emit(state.copyWith(isAdding: true, error: null));

    try {
      await _addWordToDictionaryUseCase.execute(AddWordToDictionaryParams(wordId: _wordId));
      if (isClosed) return;
      emit(state.copyWith(isAdding: false, isInDictionary: true));
    } on Exception catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isAdding: false, error: e));
    }
  }

  Future<void> _onClosePressed(ClosePressed event, Emitter<LeerWordAnnotationState> emit) async {
    if (state.isClosing) return;
    emit(state.copyWith(isClosing: true));

    await _navigator.closeWordAnnotation();
  }
}
