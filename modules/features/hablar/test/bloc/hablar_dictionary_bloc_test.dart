import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hablar/src/dictionary/bloc/hablar_dictionary_bloc.dart';
import 'package:hablar/src/navigation/hablar_navigator.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/word_fixtures.dart';

class _MockGetPersonalDictionaryUseCase extends Mock implements GetPersonalDictionaryUseCase {}

class _MockHablarNavigator extends Mock implements HablarNavigator {}

final PersonalDictionary _dictionary = PersonalDictionary(
  words: <LunfardoWord>[buildWord('grela'), buildWord('morfar')],
  totalWordCount: 13,
);

void main() {
  late _MockGetPersonalDictionaryUseCase getDictionary;
  late _MockHablarNavigator navigator;

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    getDictionary = _MockGetPersonalDictionaryUseCase();
    navigator = _MockHablarNavigator();
    when(() => getDictionary.execute(any())).thenAnswer((_) async => _dictionary);
    when(() => navigator.openWordCard(any())).thenAnswer((_) async {});
    when(() => navigator.back()).thenAnswer((_) async {});
  });

  HablarDictionaryBloc buildBloc() {
    return HablarDictionaryBloc(getPersonalDictionaryUseCase: getDictionary, navigator: navigator);
  }

  Matcher stateWith({
    required bool isLoading,
    PersonalDictionary? dictionary,
    bool isNavigating = false,
    Matcher error = isNull,
  }) {
    return isA<HablarDictionaryState>()
        .having((HablarDictionaryState s) => s.isLoading, 'isLoading', isLoading)
        .having((HablarDictionaryState s) => s.dictionary, 'dictionary', dictionary)
        .having((HablarDictionaryState s) => s.isNavigating, 'isNavigating', isNavigating)
        .having((HablarDictionaryState s) => s.error, 'error', error);
  }

  test('initial state is loading', () {
    final HablarDictionaryState state = buildBloc().state;

    expect(state.isLoading, isTrue);
    expect(state.dictionary, isNull);
  });

  group('DictionaryStarted', () {
    blocTest<HablarDictionaryBloc, HablarDictionaryState>(
      'loads the personal dictionary',
      build: buildBloc,
      act: (HablarDictionaryBloc bloc) => bloc.add(const DictionaryStarted()),
      expect: () => <Matcher>[
        stateWith(isLoading: true),
        stateWith(isLoading: false, dictionary: _dictionary),
      ],
    );

    blocTest<HablarDictionaryBloc, HablarDictionaryState>(
      'stores the error and clears the dictionary when it cannot be read',
      setUp: () {
        when(() => getDictionary.execute(any())).thenThrow(const DictionaryReadException());
      },
      build: buildBloc,
      seed: () => HablarDictionaryState(isLoading: false, dictionary: _dictionary),
      act: (HablarDictionaryBloc bloc) => bloc.add(const DictionaryStarted()),
      expect: () => <Matcher>[
        stateWith(isLoading: true, dictionary: _dictionary),
        stateWith(isLoading: false, error: isA<DictionaryReadException>()),
      ],
    );

    blocTest<HablarDictionaryBloc, HablarDictionaryState>(
      'clears a previous error on reload',
      build: buildBloc,
      seed: () => HablarDictionaryState(isLoading: false, error: Exception('old')),
      act: (HablarDictionaryBloc bloc) => bloc.add(const DictionaryStarted()),
      expect: () => <Matcher>[
        stateWith(isLoading: true),
        stateWith(isLoading: false, dictionary: _dictionary),
      ],
    );

    test('does not emit when closed while loading', () async {
      final Completer<PersonalDictionary> completer = Completer<PersonalDictionary>();
      when(() => getDictionary.execute(any())).thenAnswer((_) => completer.future);
      final HablarDictionaryBloc bloc = buildBloc();
      final List<HablarDictionaryState> states = <HablarDictionaryState>[];
      final StreamSubscription<HablarDictionaryState> subscription = bloc.stream.listen(states.add);

      bloc.add(const DictionaryStarted());
      await pumpEventQueue();
      await bloc.close();
      completer.complete(_dictionary);
      await pumpEventQueue();

      expect(states, hasLength(1));
      await subscription.cancel();
    });
  });

  group('WordPressed', () {
    blocTest<HablarDictionaryBloc, HablarDictionaryState>(
      'opens the word card',
      build: buildBloc,
      seed: () => HablarDictionaryState(isLoading: false, dictionary: _dictionary),
      act: (HablarDictionaryBloc bloc) => bloc.add(const WordPressed('morfar')),
      expect: () => <Matcher>[
        stateWith(isLoading: false, dictionary: _dictionary, isNavigating: true),
        stateWith(isLoading: false, dictionary: _dictionary),
      ],
      verify: (_) {
        verify(() => navigator.openWordCard('morfar')).called(1);
      },
    );

    test('ignores a second tap while a card is open', () async {
      final Completer<void> completer = Completer<void>();
      when(() => navigator.openWordCard(any())).thenAnswer((_) => completer.future);
      final HablarDictionaryBloc bloc = buildBloc();

      bloc
        ..add(const WordPressed('grela'))
        ..add(const WordPressed('morfar'));
      await pumpEventQueue();
      completer.complete();
      await pumpEventQueue();

      verify(() => navigator.openWordCard('grela')).called(1);
      verifyNever(() => navigator.openWordCard('morfar'));
      await bloc.close();
    });

    blocTest<HablarDictionaryBloc, HablarDictionaryState>(
      'stays usable when navigation fails',
      setUp: () {
        when(() => navigator.openWordCard(any())).thenThrow(Exception('boom'));
      },
      build: buildBloc,
      seed: () => const HablarDictionaryState(isLoading: false),
      act: (HablarDictionaryBloc bloc) => bloc.add(const WordPressed('grela')),
      expect: () => <Matcher>[
        stateWith(isLoading: false, isNavigating: true),
        stateWith(isLoading: false),
      ],
    );
  });

  group('DictionaryBackPressed', () {
    blocTest<HablarDictionaryBloc, HablarDictionaryState>(
      'goes back',
      build: buildBloc,
      act: (HablarDictionaryBloc bloc) => bloc.add(const DictionaryBackPressed()),
      verify: (_) {
        verify(() => navigator.back()).called(1);
      },
    );

    blocTest<HablarDictionaryBloc, HablarDictionaryState>(
      'is ignored while a card is opening',
      build: buildBloc,
      seed: () => const HablarDictionaryState(isNavigating: true),
      act: (HablarDictionaryBloc bloc) => bloc.add(const DictionaryBackPressed()),
      verify: (_) {
        verifyNever(() => navigator.back());
      },
    );
  });
}
