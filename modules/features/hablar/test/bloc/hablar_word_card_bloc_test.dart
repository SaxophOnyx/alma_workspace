import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hablar/src/navigation/hablar_navigator.dart';
import 'package:hablar/src/word_card/bloc/hablar_word_card_bloc.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/word_fixtures.dart';

class _MockGetWordOfTheDayUseCase extends Mock implements GetWordOfTheDayUseCase {}

class _MockGetLunfardoWordUseCase extends Mock implements GetLunfardoWordUseCase {}

class _MockIsWordInDictionaryUseCase extends Mock implements IsWordInDictionaryUseCase {}

class _MockAddWordToDictionaryUseCase extends Mock implements AddWordToDictionaryUseCase {}

class _MockMarkWordEncounteredUseCase extends Mock implements MarkWordEncounteredUseCase {}

class _MockHablarNavigator extends Mock implements HablarNavigator {}

final LunfardoWord _grela = buildWord('grela');
final LunfardoWord _morfar = buildWord('morfar', textId: 'mi_noche_triste');

Matcher _hasWordId<T>(String Function(T params) read, String wordId) {
  return isA<T>().having(read, 'wordId', wordId);
}

void main() {
  late _MockGetWordOfTheDayUseCase getWordOfTheDay;
  late _MockGetLunfardoWordUseCase getWord;
  late _MockIsWordInDictionaryUseCase isInDictionary;
  late _MockAddWordToDictionaryUseCase addWord;
  late _MockMarkWordEncounteredUseCase markEncountered;
  late _MockHablarNavigator navigator;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const GetLunfardoWordParams(wordId: ''));
    registerFallbackValue(const IsWordInDictionaryParams(wordId: ''));
    registerFallbackValue(const AddWordToDictionaryParams(wordId: ''));
    registerFallbackValue(const MarkWordEncounteredParams(wordId: ''));
  });

  setUp(() {
    getWordOfTheDay = _MockGetWordOfTheDayUseCase();
    getWord = _MockGetLunfardoWordUseCase();
    isInDictionary = _MockIsWordInDictionaryUseCase();
    addWord = _MockAddWordToDictionaryUseCase();
    markEncountered = _MockMarkWordEncounteredUseCase();
    navigator = _MockHablarNavigator();
    when(() => getWordOfTheDay.execute(any())).thenAnswer((_) async => _grela);
    when(() => getWord.execute(any())).thenAnswer((_) async => _morfar);
    when(() => isInDictionary.execute(any())).thenAnswer((_) async => false);
    when(() => addWord.execute(any())).thenAnswer((_) async {});
    when(() => markEncountered.execute(any())).thenAnswer((_) async {});
    when(() => navigator.openText(any())).thenAnswer((_) async {});
    when(() => navigator.back()).thenAnswer((_) async {});
  });

  HablarWordCardBloc buildBloc({String? wordId}) {
    return HablarWordCardBloc(
      wordId: wordId,
      getWordOfTheDayUseCase: getWordOfTheDay,
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
    bool isNavigating = false,
    Matcher error = isNull,
  }) {
    return isA<HablarWordCardState>()
        .having((HablarWordCardState s) => s.isLoading, 'isLoading', isLoading)
        .having((HablarWordCardState s) => s.word, 'word', word)
        .having((HablarWordCardState s) => s.isInDictionary, 'isInDictionary', isInDictionary)
        .having((HablarWordCardState s) => s.isAdding, 'isAdding', isAdding)
        .having((HablarWordCardState s) => s.isNavigating, 'isNavigating', isNavigating)
        .having((HablarWordCardState s) => s.error, 'error', error);
  }

  group('WordCardStarted', () {
    blocTest<HablarWordCardBloc, HablarWordCardState>(
      'shows the word of the day when no word is given',
      build: buildBloc,
      act: (HablarWordCardBloc bloc) => bloc.add(const WordCardStarted()),
      expect: () => <Matcher>[
        stateWith(isLoading: true),
        stateWith(isLoading: false, word: _grela),
      ],
      verify: (_) {
        verify(() => getWordOfTheDay.execute(any())).called(1);
        verifyNever(() => getWord.execute(any()));
        verify(
          () => markEncountered.execute(
            any(that: _hasWordId((MarkWordEncounteredParams p) => p.wordId, 'grela')),
          ),
        ).called(1);
        verify(
          () => isInDictionary.execute(
            any(that: _hasWordId((IsWordInDictionaryParams p) => p.wordId, 'grela')),
          ),
        ).called(1);
      },
    );

    blocTest<HablarWordCardBloc, HablarWordCardState>(
      'shows the requested word already in the dictionary',
      setUp: () {
        when(() => isInDictionary.execute(any())).thenAnswer((_) async => true);
      },
      build: () => buildBloc(wordId: 'morfar'),
      act: (HablarWordCardBloc bloc) => bloc.add(const WordCardStarted()),
      expect: () => <Matcher>[
        stateWith(isLoading: true),
        stateWith(isLoading: false, word: _morfar, isInDictionary: true),
      ],
      verify: (_) {
        verify(
          () => getWord.execute(any(that: _hasWordId((GetLunfardoWordParams p) => p.wordId, 'morfar'))),
        ).called(1);
        verifyNever(() => getWordOfTheDay.execute(any()));
        verify(
          () => markEncountered.execute(
            any(that: _hasWordId((MarkWordEncounteredParams p) => p.wordId, 'morfar')),
          ),
        ).called(1);
      },
    );

    blocTest<HablarWordCardBloc, HablarWordCardState>(
      'stores the error and skips the rest when the word cannot be loaded',
      setUp: () {
        when(() => getWordOfTheDay.execute(any())).thenThrow(const WordOfTheDayReadException());
      },
      build: buildBloc,
      act: (HablarWordCardBloc bloc) => bloc.add(const WordCardStarted()),
      expect: () => <Matcher>[
        stateWith(isLoading: true),
        stateWith(isLoading: false, error: isA<WordOfTheDayReadException>()),
      ],
      verify: (_) {
        verifyNever(() => markEncountered.execute(any()));
        verifyNever(() => isInDictionary.execute(any()));
      },
    );

    blocTest<HablarWordCardBloc, HablarWordCardState>(
      'still shows the word when the encounter cannot be recorded',
      setUp: () {
        when(() => markEncountered.execute(any())).thenThrow(const EncounteredWordsWriteException());
      },
      build: buildBloc,
      act: (HablarWordCardBloc bloc) => bloc.add(const WordCardStarted()),
      expect: () => <Matcher>[
        stateWith(isLoading: true),
        stateWith(isLoading: false, word: _grela),
      ],
    );

    blocTest<HablarWordCardBloc, HablarWordCardState>(
      'still shows the word when the dictionary cannot be read',
      setUp: () {
        when(() => isInDictionary.execute(any())).thenThrow(const DictionaryReadException());
      },
      build: buildBloc,
      act: (HablarWordCardBloc bloc) => bloc.add(const WordCardStarted()),
      expect: () => <Matcher>[
        stateWith(isLoading: true),
        stateWith(isLoading: false, word: _grela, error: isA<DictionaryReadException>()),
      ],
    );

    blocTest<HablarWordCardBloc, HablarWordCardState>(
      'clears a previous error when loading again',
      build: buildBloc,
      seed: () => HablarWordCardState(isLoading: false, error: Exception('old')),
      act: (HablarWordCardBloc bloc) => bloc.add(const WordCardStarted()),
      expect: () => <Matcher>[
        stateWith(isLoading: true),
        stateWith(isLoading: false, word: _grela),
      ],
    );

    test('does not emit when closed while loading', () async {
      final Completer<LunfardoWord> completer = Completer<LunfardoWord>();
      when(() => getWordOfTheDay.execute(any())).thenAnswer((_) => completer.future);
      final HablarWordCardBloc bloc = buildBloc();
      final List<HablarWordCardState> states = <HablarWordCardState>[];
      final StreamSubscription<HablarWordCardState> subscription = bloc.stream.listen(states.add);

      bloc.add(const WordCardStarted());
      await pumpEventQueue();
      await bloc.close();
      completer.complete(_grela);
      await pumpEventQueue();

      expect(states, hasLength(1));
      verifyNever(() => markEncountered.execute(any()));
      await subscription.cancel();
    });
  });

  group('AddPressed', () {
    blocTest<HablarWordCardBloc, HablarWordCardState>(
      'saves the word and switches to "In dictionary"',
      build: buildBloc,
      seed: () => HablarWordCardState(isLoading: false, word: _grela),
      act: (HablarWordCardBloc bloc) => bloc.add(const AddPressed()),
      expect: () => <Matcher>[
        stateWith(isLoading: false, word: _grela, isAdding: true),
        stateWith(isLoading: false, word: _grela, isInDictionary: true),
      ],
      verify: (_) {
        verify(
          () => addWord.execute(any(that: _hasWordId((AddWordToDictionaryParams p) => p.wordId, 'grela'))),
        ).called(1);
      },
    );

    blocTest<HablarWordCardBloc, HablarWordCardState>(
      'clears a previous error when adding',
      build: buildBloc,
      seed: () => HablarWordCardState(isLoading: false, word: _grela, error: const DictionaryReadException()),
      act: (HablarWordCardBloc bloc) => bloc.add(const AddPressed()),
      expect: () => <Matcher>[
        stateWith(isLoading: false, word: _grela, isAdding: true),
        stateWith(isLoading: false, word: _grela, isInDictionary: true),
      ],
    );

    blocTest<HablarWordCardBloc, HablarWordCardState>(
      'keeps the button available and stores the error when saving fails',
      setUp: () {
        when(() => addWord.execute(any())).thenThrow(const DictionaryWriteException());
      },
      build: buildBloc,
      seed: () => HablarWordCardState(isLoading: false, word: _grela),
      act: (HablarWordCardBloc bloc) => bloc.add(const AddPressed()),
      expect: () => <Matcher>[
        stateWith(isLoading: false, word: _grela, isAdding: true),
        stateWith(isLoading: false, word: _grela, error: isA<DictionaryWriteException>()),
      ],
    );

    blocTest<HablarWordCardBloc, HablarWordCardState>(
      'is ignored when the word is already saved',
      build: buildBloc,
      seed: () => HablarWordCardState(isLoading: false, word: _grela, isInDictionary: true),
      act: (HablarWordCardBloc bloc) => bloc.add(const AddPressed()),
      expect: () => <Matcher>[],
      verify: (_) {
        verifyNever(() => addWord.execute(any()));
      },
    );

    blocTest<HablarWordCardBloc, HablarWordCardState>(
      'is ignored without a word',
      build: buildBloc,
      seed: () => const HablarWordCardState(isLoading: false),
      act: (HablarWordCardBloc bloc) => bloc.add(const AddPressed()),
      expect: () => <Matcher>[],
    );

    blocTest<HablarWordCardBloc, HablarWordCardState>(
      'saves only once on a double tap',
      build: buildBloc,
      seed: () => HablarWordCardState(isLoading: false, word: _grela),
      act: (HablarWordCardBloc bloc) => bloc
        ..add(const AddPressed())
        ..add(const AddPressed()),
      verify: (_) {
        verify(() => addWord.execute(any())).called(1);
      },
    );
  });

  group('OpenTextPressed', () {
    blocTest<HablarWordCardBloc, HablarWordCardState>(
      'opens the text of the example',
      build: buildBloc,
      seed: () => HablarWordCardState(isLoading: false, word: _morfar),
      act: (HablarWordCardBloc bloc) => bloc.add(const OpenTextPressed()),
      expect: () => <Matcher>[
        stateWith(isLoading: false, word: _morfar, isNavigating: true),
        stateWith(isLoading: false, word: _morfar),
      ],
      verify: (_) {
        verify(() => navigator.openText('mi_noche_triste')).called(1);
      },
    );

    test('ignores a second tap while the text is open', () async {
      final Completer<void> completer = Completer<void>();
      when(() => navigator.openText(any())).thenAnswer((_) => completer.future);
      final HablarWordCardBloc bloc = buildBloc();
      bloc.emit(HablarWordCardState(isLoading: false, word: _grela));

      bloc
        ..add(const OpenTextPressed())
        ..add(const OpenTextPressed());
      await pumpEventQueue();
      completer.complete();
      await pumpEventQueue();

      verify(() => navigator.openText('yira_yira')).called(1);
      await bloc.close();
    });

    blocTest<HablarWordCardBloc, HablarWordCardState>(
      'is ignored without a word',
      build: buildBloc,
      seed: () => const HablarWordCardState(isLoading: false),
      act: (HablarWordCardBloc bloc) => bloc.add(const OpenTextPressed()),
      expect: () => <Matcher>[],
      verify: (_) {
        verifyNever(() => navigator.openText(any()));
      },
    );

    blocTest<HablarWordCardBloc, HablarWordCardState>(
      'shows "In dictionary" on return when the word was added while reading',
      setUp: () {
        when(() => isInDictionary.execute(any())).thenAnswer((_) async => true);
      },
      build: buildBloc,
      seed: () => HablarWordCardState(isLoading: false, word: _grela),
      act: (HablarWordCardBloc bloc) => bloc.add(const OpenTextPressed()),
      expect: () => <Matcher>[
        stateWith(isLoading: false, word: _grela, isNavigating: true),
        stateWith(isLoading: false, word: _grela, isInDictionary: true),
      ],
      verify: (_) {
        verify(
          () => isInDictionary.execute(
            any(that: isA<IsWordInDictionaryParams>().having((IsWordInDictionaryParams p) => p.wordId, 'wordId', 'grela')),
          ),
        ).called(1);
      },
    );

    blocTest<HablarWordCardBloc, HablarWordCardState>(
      'keeps the shown dictionary state when it cannot be re-read on return',
      setUp: () {
        when(() => isInDictionary.execute(any())).thenThrow(const DictionaryReadException());
      },
      build: buildBloc,
      seed: () => HablarWordCardState(isLoading: false, word: _grela),
      act: (HablarWordCardBloc bloc) => bloc.add(const OpenTextPressed()),
      expect: () => <Matcher>[
        stateWith(isLoading: false, word: _grela, isNavigating: true),
        stateWith(isLoading: false, word: _grela),
      ],
    );

    blocTest<HablarWordCardBloc, HablarWordCardState>(
      'stays usable when navigation fails',
      setUp: () {
        when(() => navigator.openText(any())).thenThrow(Exception('boom'));
      },
      build: buildBloc,
      seed: () => HablarWordCardState(isLoading: false, word: _grela),
      act: (HablarWordCardBloc bloc) => bloc.add(const OpenTextPressed()),
      expect: () => <Matcher>[
        stateWith(isLoading: false, word: _grela, isNavigating: true),
        stateWith(isLoading: false, word: _grela),
      ],
    );
  });

  group('WordCardBackPressed', () {
    blocTest<HablarWordCardBloc, HablarWordCardState>(
      'goes back',
      build: buildBloc,
      act: (HablarWordCardBloc bloc) => bloc.add(const WordCardBackPressed()),
      verify: (_) {
        verify(() => navigator.back()).called(1);
      },
    );

    blocTest<HablarWordCardBloc, HablarWordCardState>(
      'is ignored while the text is opening',
      build: buildBloc,
      seed: () => const HablarWordCardState(isNavigating: true),
      act: (HablarWordCardBloc bloc) => bloc.add(const WordCardBackPressed()),
      verify: (_) {
        verifyNever(() => navigator.back());
      },
    );
  });
}
