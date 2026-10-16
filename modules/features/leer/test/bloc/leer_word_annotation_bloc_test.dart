import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leer/src/annotation/bloc/leer_word_annotation_bloc.dart';
import 'package:leer/src/navigation/leer_navigator.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetLunfardoWordUseCase extends Mock implements GetLunfardoWordUseCase {}

class _MockIsWordInDictionaryUseCase extends Mock implements IsWordInDictionaryUseCase {}

class _MockAddWordToDictionaryUseCase extends Mock implements AddWordToDictionaryUseCase {}

class _MockLeerNavigator extends Mock implements LeerNavigator {}

class _MockMarkWordEncounteredUseCase extends Mock implements MarkWordEncounteredUseCase {}

const LunfardoWord _grela = LunfardoWord(
  id: 'grela',
  word: 'grela',
  pronunciation: '/ˈɣɾe.la/',
  meaning: 'fickle fate',
  etymology: <String>['Italian grilla'],
  example: WordExample(
    line: TextLine(segments: <TextSegment>[TextSegment(text: 'grela', wordId: 'grela')]),
    title: 'Yira, yira',
    year: 1930,
    textId: 'yira_yira',
  ),
  related: <String>[],
);

void main() {
  late _MockGetLunfardoWordUseCase getWord;
  late _MockIsWordInDictionaryUseCase isInDictionary;
  late _MockAddWordToDictionaryUseCase addWord;
  late _MockLeerNavigator navigator;
  late _MockMarkWordEncounteredUseCase markEncountered;

  setUpAll(() {
    registerFallbackValue(const GetLunfardoWordParams(wordId: ''));
    registerFallbackValue(const IsWordInDictionaryParams(wordId: ''));
    registerFallbackValue(const AddWordToDictionaryParams(wordId: ''));
    registerFallbackValue(const MarkWordEncounteredParams(wordId: ''));
  });

  setUp(() {
    getWord = _MockGetLunfardoWordUseCase();
    isInDictionary = _MockIsWordInDictionaryUseCase();
    addWord = _MockAddWordToDictionaryUseCase();
    navigator = _MockLeerNavigator();
    markEncountered = _MockMarkWordEncounteredUseCase();
    when(() => markEncountered.execute(any())).thenAnswer((_) async {});
    when(() => getWord.execute(any())).thenAnswer((_) async => _grela);
    when(() => isInDictionary.execute(any())).thenAnswer((_) async => false);
    when(() => addWord.execute(any())).thenAnswer((_) async {});
    when(() => navigator.closeWordAnnotation()).thenAnswer((_) async {});
  });

  LeerWordAnnotationBloc buildBloc() {
    return LeerWordAnnotationBloc(
      wordId: 'grela',
      getLunfardoWordUseCase: getWord,
      isWordInDictionaryUseCase: isInDictionary,
      addWordToDictionaryUseCase: addWord,
      markWordEncounteredUseCase: markEncountered,
      navigator: navigator,
    );
  }

  Matcher stateWith({
    required bool isLoading,
    LunfardoWord? word,
    bool isInDictionary = false,
    bool isAdding = false,
    bool isClosing = false,
    Matcher error = isNull,
  }) {
    return isA<LeerWordAnnotationState>()
        .having((LeerWordAnnotationState s) => s.isLoading, 'isLoading', isLoading)
        .having((LeerWordAnnotationState s) => s.word, 'word', word)
        .having((LeerWordAnnotationState s) => s.isInDictionary, 'isInDictionary', isInDictionary)
        .having((LeerWordAnnotationState s) => s.isAdding, 'isAdding', isAdding)
        .having((LeerWordAnnotationState s) => s.isClosing, 'isClosing', isClosing)
        .having((LeerWordAnnotationState s) => s.error, 'error', error);
  }

  group('AnnotationStarted', () {
    blocTest<LeerWordAnnotationBloc, LeerWordAnnotationState>(
      'loads the word and whether it is already saved',
      setUp: () {
        when(() => isInDictionary.execute(any())).thenAnswer((_) async => true);
      },
      build: buildBloc,
      act: (LeerWordAnnotationBloc bloc) => bloc.add(const AnnotationStarted()),
      expect: () => <Matcher>[
        stateWith(isLoading: true),
        stateWith(isLoading: false, word: _grela, isInDictionary: true),
      ],
      verify: (_) {
        verify(
          () => getWord.execute(
            any(that: isA<GetLunfardoWordParams>().having((GetLunfardoWordParams p) => p.wordId, 'wordId', 'grela')),
          ),
        ).called(1);
        verify(
          () => isInDictionary.execute(
            any(
              that: isA<IsWordInDictionaryParams>().having(
                (IsWordInDictionaryParams p) => p.wordId,
                'wordId',
                'grela',
              ),
            ),
          ),
        ).called(1);
      },
    );

    blocTest<LeerWordAnnotationBloc, LeerWordAnnotationState>(
      'stores the error and skips the dictionary when the word cannot be loaded',
      setUp: () {
        when(() => getWord.execute(any())).thenThrow(const LunfardoWordNotFoundException());
      },
      build: buildBloc,
      act: (LeerWordAnnotationBloc bloc) => bloc.add(const AnnotationStarted()),
      expect: () => <Matcher>[
        stateWith(isLoading: true),
        stateWith(isLoading: false, error: isA<LunfardoWordNotFoundException>()),
      ],
      verify: (_) {
        verifyNever(() => isInDictionary.execute(any()));
      },
    );

    blocTest<LeerWordAnnotationBloc, LeerWordAnnotationState>(
      'still shows the word when the dictionary cannot be read',
      setUp: () {
        when(() => isInDictionary.execute(any())).thenThrow(const DictionaryReadException());
      },
      build: buildBloc,
      act: (LeerWordAnnotationBloc bloc) => bloc.add(const AnnotationStarted()),
      expect: () => <Matcher>[
        stateWith(isLoading: true),
        stateWith(isLoading: false, word: _grela, error: isA<DictionaryReadException>()),
      ],
    );

    test('does not emit when closed while loading', () async {
      final Completer<LunfardoWord> completer = Completer<LunfardoWord>();
      when(() => getWord.execute(any())).thenAnswer((_) => completer.future);
      final LeerWordAnnotationBloc bloc = buildBloc();
      final List<LeerWordAnnotationState> states = <LeerWordAnnotationState>[];
      final StreamSubscription<LeerWordAnnotationState> subscription = bloc.stream.listen(states.add);

      bloc.add(const AnnotationStarted());
      await pumpEventQueue();
      await bloc.close();
      completer.complete(_grela);
      await pumpEventQueue();

      expect(states, hasLength(1));
      verifyNever(() => isInDictionary.execute(any()));
      await subscription.cancel();
    });
  });

  group('AnnotationStarted encounter tracking', () {
    blocTest<LeerWordAnnotationBloc, LeerWordAnnotationState>(
      'records the word as encountered once it loads',
      build: buildBloc,
      act: (LeerWordAnnotationBloc bloc) => bloc.add(const AnnotationStarted()),
      verify: (_) {
        verify(
          () => markEncountered.execute(
            any(
              that: isA<MarkWordEncounteredParams>().having(
                (MarkWordEncounteredParams p) => p.wordId,
                'wordId',
                'grela',
              ),
            ),
          ),
        ).called(1);
      },
    );

    blocTest<LeerWordAnnotationBloc, LeerWordAnnotationState>(
      'still shows the word when the encounter cannot be recorded',
      setUp: () {
        when(() => markEncountered.execute(any())).thenThrow(const EncounteredWordsWriteException());
      },
      build: buildBloc,
      act: (LeerWordAnnotationBloc bloc) => bloc.add(const AnnotationStarted()),
      expect: () => <Matcher>[
        stateWith(isLoading: true),
        stateWith(isLoading: false, word: _grela),
      ],
    );

    blocTest<LeerWordAnnotationBloc, LeerWordAnnotationState>(
      'does not record an encounter when the word cannot be loaded',
      setUp: () {
        when(() => getWord.execute(any())).thenThrow(const LunfardoWordNotFoundException());
      },
      build: buildBloc,
      act: (LeerWordAnnotationBloc bloc) => bloc.add(const AnnotationStarted()),
      verify: (_) {
        verifyNever(() => markEncountered.execute(any()));
      },
    );
  });

  group('AddPressed', () {
    blocTest<LeerWordAnnotationBloc, LeerWordAnnotationState>(
      'saves the word and switches to "In dictionary"',
      build: buildBloc,
      seed: () => const LeerWordAnnotationState(isLoading: false, word: _grela),
      act: (LeerWordAnnotationBloc bloc) => bloc.add(const AddPressed()),
      expect: () => <Matcher>[
        stateWith(isLoading: false, word: _grela, isAdding: true),
        stateWith(isLoading: false, word: _grela, isInDictionary: true),
      ],
      verify: (_) {
        verify(
          () => addWord.execute(
            any(
              that: isA<AddWordToDictionaryParams>().having(
                (AddWordToDictionaryParams p) => p.wordId,
                'wordId',
                'grela',
              ),
            ),
          ),
        ).called(1);
      },
    );

    blocTest<LeerWordAnnotationBloc, LeerWordAnnotationState>(
      'clears a previous dictionary error when saving succeeds',
      build: buildBloc,
      seed: () => const LeerWordAnnotationState(isLoading: false, word: _grela, error: DictionaryReadException()),
      act: (LeerWordAnnotationBloc bloc) => bloc.add(const AddPressed()),
      expect: () => <Matcher>[
        stateWith(isLoading: false, word: _grela, isAdding: true),
        stateWith(isLoading: false, word: _grela, isInDictionary: true),
      ],
    );

    blocTest<LeerWordAnnotationBloc, LeerWordAnnotationState>(
      'stores the error and keeps the button when saving fails',
      setUp: () {
        when(() => addWord.execute(any())).thenThrow(const DictionaryWriteException());
      },
      build: buildBloc,
      seed: () => const LeerWordAnnotationState(isLoading: false, word: _grela),
      act: (LeerWordAnnotationBloc bloc) => bloc.add(const AddPressed()),
      expect: () => <Matcher>[
        stateWith(isLoading: false, word: _grela, isAdding: true),
        stateWith(isLoading: false, word: _grela, error: isA<DictionaryWriteException>()),
      ],
    );

    blocTest<LeerWordAnnotationBloc, LeerWordAnnotationState>(
      'does nothing when the word is already saved',
      build: buildBloc,
      seed: () => const LeerWordAnnotationState(isLoading: false, word: _grela, isInDictionary: true),
      act: (LeerWordAnnotationBloc bloc) => bloc.add(const AddPressed()),
      expect: () => <Matcher>[],
      verify: (_) {
        verifyNever(() => addWord.execute(any()));
      },
    );

    blocTest<LeerWordAnnotationBloc, LeerWordAnnotationState>(
      'does nothing without a loaded word',
      build: buildBloc,
      seed: () => const LeerWordAnnotationState(isLoading: false),
      act: (LeerWordAnnotationBloc bloc) => bloc.add(const AddPressed()),
      expect: () => <Matcher>[],
      verify: (_) {
        verifyNever(() => addWord.execute(any()));
      },
    );

    blocTest<LeerWordAnnotationBloc, LeerWordAnnotationState>(
      'saves only once on a rapid double tap',
      build: buildBloc,
      seed: () => const LeerWordAnnotationState(isLoading: false, word: _grela),
      act: (LeerWordAnnotationBloc bloc) {
        bloc
          ..add(const AddPressed())
          ..add(const AddPressed());
      },
      expect: () => <Matcher>[
        stateWith(isLoading: false, word: _grela, isAdding: true),
        stateWith(isLoading: false, word: _grela, isInDictionary: true),
      ],
      verify: (_) {
        verify(() => addWord.execute(any())).called(1);
      },
    );
  });

  group('ClosePressed', () {
    blocTest<LeerWordAnnotationBloc, LeerWordAnnotationState>(
      'closes the popup',
      build: buildBloc,
      seed: () => const LeerWordAnnotationState(isLoading: false, word: _grela),
      act: (LeerWordAnnotationBloc bloc) => bloc.add(const ClosePressed()),
      expect: () => <Matcher>[
        stateWith(isLoading: false, word: _grela, isClosing: true),
      ],
      verify: (_) {
        verify(() => navigator.closeWordAnnotation()).called(1);
      },
    );

    blocTest<LeerWordAnnotationBloc, LeerWordAnnotationState>(
      'closes only once on a rapid double tap',
      build: buildBloc,
      seed: () => const LeerWordAnnotationState(isLoading: false, word: _grela),
      act: (LeerWordAnnotationBloc bloc) {
        bloc
          ..add(const ClosePressed())
          ..add(const ClosePressed());
      },
      verify: (_) {
        verify(() => navigator.closeWordAnnotation()).called(1);
      },
    );
  });
}
