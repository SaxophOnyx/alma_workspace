import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hablar/src/main/bloc/hablar_main_bloc.dart';
import 'package:hablar/src/main/misc/hablar_entry.dart';
import 'package:hablar/src/navigation/hablar_navigator.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/word_fixtures.dart';

class _MockGetPersonalDictionaryUseCase extends Mock implements GetPersonalDictionaryUseCase {}

class _MockHablarNavigator extends Mock implements HablarNavigator {}

PersonalDictionary _dictionary(int count) {
  return PersonalDictionary(
    words: <LunfardoWord>[for (int i = 0; i < count; i++) buildWord('word$i')],
    totalWordCount: 13,
  );
}

void main() {
  late _MockGetPersonalDictionaryUseCase getDictionary;
  late _MockHablarNavigator navigator;

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    getDictionary = _MockGetPersonalDictionaryUseCase();
    navigator = _MockHablarNavigator();
    when(() => getDictionary.execute(any())).thenAnswer((_) async => _dictionary(2));
    when(() => navigator.openWordOfTheDay()).thenAnswer((_) async {});
    when(() => navigator.openDictionary()).thenAnswer((_) async {});
    when(() => navigator.openQuiz()).thenAnswer((_) async {});
    when(() => navigator.back()).thenAnswer((_) async {});
  });

  HablarMainBloc buildBloc() => HablarMainBloc(getPersonalDictionaryUseCase: getDictionary, navigator: navigator);

  Matcher stateWith({int? dictionaryCount, bool isNavigating = false}) {
    return isA<HablarMainState>()
        .having((HablarMainState s) => s.dictionaryCount, 'dictionaryCount', dictionaryCount)
        .having((HablarMainState s) => s.isNavigating, 'isNavigating', isNavigating);
  }

  test('initial state has no counter', () {
    final HablarMainState state = buildBloc().state;

    expect(state.dictionaryCount, isNull);
    expect(state.isNavigating, isFalse);
  });

  group('HablarStarted', () {
    blocTest<HablarMainBloc, HablarMainState>(
      'loads the dictionary counter',
      build: buildBloc,
      act: (HablarMainBloc bloc) => bloc.add(const HablarStarted()),
      expect: () => <Matcher>[stateWith(dictionaryCount: 2)],
    );

    blocTest<HablarMainBloc, HablarMainState>(
      'shows no counter when the dictionary cannot be read',
      setUp: () {
        when(() => getDictionary.execute(any())).thenThrow(const DictionaryReadException());
      },
      build: buildBloc,
      seed: () => const HablarMainState(dictionaryCount: 5),
      act: (HablarMainBloc bloc) => bloc.add(const HablarStarted()),
      expect: () => <Matcher>[stateWith()],
    );

    test('does not emit when closed while loading', () async {
      final Completer<PersonalDictionary> completer = Completer<PersonalDictionary>();
      when(() => getDictionary.execute(any())).thenAnswer((_) => completer.future);
      final HablarMainBloc bloc = buildBloc();
      final List<HablarMainState> states = <HablarMainState>[];
      final StreamSubscription<HablarMainState> subscription = bloc.stream.listen(states.add);

      bloc.add(const HablarStarted());
      await pumpEventQueue();
      await bloc.close();
      completer.complete(_dictionary(1));
      await pumpEventQueue();

      expect(states, isEmpty);
      await subscription.cancel();
    });
  });

  group('EntryPressed', () {
    blocTest<HablarMainBloc, HablarMainState>(
      'opens the word of the day and refreshes the counter on return',
      setUp: () {
        int calls = 0;
        when(() => getDictionary.execute(any())).thenAnswer((_) async => _dictionary(++calls == 1 ? 3 : 0));
      },
      build: buildBloc,
      seed: () => const HablarMainState(dictionaryCount: 2),
      act: (HablarMainBloc bloc) => bloc.add(const EntryPressed(HablarEntry.wordOfTheDay)),
      expect: () => <Matcher>[
        stateWith(dictionaryCount: 2, isNavigating: true),
        stateWith(dictionaryCount: 2),
        stateWith(dictionaryCount: 3),
      ],
      verify: (_) {
        verify(() => navigator.openWordOfTheDay()).called(1);
      },
    );

    blocTest<HablarMainBloc, HablarMainState>(
      'opens the dictionary',
      build: buildBloc,
      act: (HablarMainBloc bloc) => bloc.add(const EntryPressed(HablarEntry.dictionary)),
      verify: (_) {
        verify(() => navigator.openDictionary()).called(1);
        verifyNever(() => navigator.openWordOfTheDay());
        verifyNever(() => navigator.openQuiz());
      },
    );

    blocTest<HablarMainBloc, HablarMainState>(
      'opens the quiz',
      build: buildBloc,
      act: (HablarMainBloc bloc) => bloc.add(const EntryPressed(HablarEntry.quiz)),
      verify: (_) {
        verify(() => navigator.openQuiz()).called(1);
      },
    );

    test('ignores a second entry while the first one is open', () async {
      final Completer<void> completer = Completer<void>();
      when(() => navigator.openWordOfTheDay()).thenAnswer((_) => completer.future);
      final HablarMainBloc bloc = buildBloc();

      bloc
        ..add(const EntryPressed(HablarEntry.wordOfTheDay))
        ..add(const EntryPressed(HablarEntry.quiz));
      await pumpEventQueue();
      completer.complete();
      await pumpEventQueue();

      verify(() => navigator.openWordOfTheDay()).called(1);
      verifyNever(() => navigator.openQuiz());
      await bloc.close();
    });

    blocTest<HablarMainBloc, HablarMainState>(
      'stays usable when navigation fails',
      setUp: () {
        when(() => navigator.openQuiz()).thenThrow(Exception('boom'));
      },
      build: buildBloc,
      act: (HablarMainBloc bloc) => bloc.add(const EntryPressed(HablarEntry.quiz)),
      expect: () => <Matcher>[
        stateWith(isNavigating: true),
        stateWith(),
        stateWith(dictionaryCount: 2),
      ],
    );
  });

  group('HablarBackPressed', () {
    blocTest<HablarMainBloc, HablarMainState>(
      'goes back',
      build: buildBloc,
      act: (HablarMainBloc bloc) => bloc.add(const HablarBackPressed()),
      verify: (_) {
        verify(() => navigator.back()).called(1);
      },
    );

    blocTest<HablarMainBloc, HablarMainState>(
      'is ignored while another screen is opening',
      build: buildBloc,
      seed: () => const HablarMainState(isNavigating: true),
      act: (HablarMainBloc bloc) => bloc.add(const HablarBackPressed()),
      verify: (_) {
        verifyNever(() => navigator.back());
      },
    );
  });
}
