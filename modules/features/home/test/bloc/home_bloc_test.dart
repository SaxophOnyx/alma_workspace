import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home/src/bloc/home_bloc.dart';
import 'package:home/src/misc/home_entry.dart';
import 'package:home/src/navigation/home_navigator.dart';
import 'package:mocktail/mocktail.dart';

class _MockHomeNavigator extends Mock implements HomeNavigator {}

void main() {
  late _MockHomeNavigator navigator;

  setUp(() {
    navigator = _MockHomeNavigator();
    when(() => navigator.openRespirar()).thenAnswer((_) async {});
    when(() => navigator.openHablar()).thenAnswer((_) async {});
    when(() => navigator.openLeer()).thenAnswer((_) async {});
  });

  HomeBloc buildBloc({Duration highlightDuration = Duration.zero}) {
    return HomeBloc(navigator: navigator, highlightDuration: highlightDuration);
  }

  Matcher stateWith({required HomeEntry? highlightedEntry, required bool isNavigating}) {
    return isA<HomeState>()
        .having((HomeState s) => s.highlightedEntry, 'highlightedEntry', highlightedEntry)
        .having((HomeState s) => s.isNavigating, 'isNavigating', isNavigating);
  }

  test('initial state has no highlight and is idle', () {
    final HomeState state = buildBloc().state;

    expect(state.highlightedEntry, isNull);
    expect(state.isNavigating, isFalse);
  });

  group('EntryPressed', () {
    blocTest<HomeBloc, HomeState>(
      'highlights Respirar, opens it, then clears the highlight on return',
      build: buildBloc,
      act: (HomeBloc bloc) => bloc.add(const EntryPressed(HomeEntry.respirar)),
      expect: () => <Matcher>[
        stateWith(highlightedEntry: HomeEntry.respirar, isNavigating: true),
        stateWith(highlightedEntry: null, isNavigating: false),
      ],
      verify: (_) {
        verify(() => navigator.openRespirar()).called(1);
        verifyNoMoreInteractions(navigator);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'opens Hablar for the Hablar line',
      build: buildBloc,
      act: (HomeBloc bloc) => bloc.add(const EntryPressed(HomeEntry.hablar)),
      expect: () => <Matcher>[
        stateWith(highlightedEntry: HomeEntry.hablar, isNavigating: true),
        stateWith(highlightedEntry: null, isNavigating: false),
      ],
      verify: (_) {
        verify(() => navigator.openHablar()).called(1);
        verifyNoMoreInteractions(navigator);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'opens Leer for the Leer line',
      build: buildBloc,
      act: (HomeBloc bloc) => bloc.add(const EntryPressed(HomeEntry.leer)),
      verify: (_) {
        verify(() => navigator.openLeer()).called(1);
        verifyNoMoreInteractions(navigator);
      },
    );

    test('waits for the highlight duration before navigating', () async {
      final HomeBloc bloc = buildBloc(highlightDuration: const Duration(milliseconds: 100));

      bloc.add(const EntryPressed(HomeEntry.respirar));
      await Future<void>.delayed(const Duration(milliseconds: 30));
      verifyNever(() => navigator.openRespirar());

      await Future<void>.delayed(const Duration(milliseconds: 120));
      verify(() => navigator.openRespirar()).called(1);

      await bloc.close();
    });

    test('keeps the highlight while the opened module is on top', () async {
      final Completer<void> completer = Completer<void>();
      when(() => navigator.openRespirar()).thenAnswer((_) => completer.future);
      final HomeBloc bloc = buildBloc();

      bloc.add(const EntryPressed(HomeEntry.respirar));
      await pumpEventQueue();
      expect(bloc.state.highlightedEntry, HomeEntry.respirar);
      expect(bloc.state.isNavigating, isTrue);

      completer.complete();
      await pumpEventQueue();
      expect(bloc.state.highlightedEntry, isNull);
      expect(bloc.state.isNavigating, isFalse);

      await bloc.close();
    });

    test('ignores other lines while a module is open', () async {
      final Completer<void> completer = Completer<void>();
      when(() => navigator.openRespirar()).thenAnswer((_) => completer.future);
      final HomeBloc bloc = buildBloc();

      bloc
        ..add(const EntryPressed(HomeEntry.respirar))
        ..add(const EntryPressed(HomeEntry.leer));
      await pumpEventQueue();
      completer.complete();
      await pumpEventQueue();

      verify(() => navigator.openRespirar()).called(1);
      verifyNever(() => navigator.openLeer());

      await bloc.close();
    });

    blocTest<HomeBloc, HomeState>(
      'navigates only once when tapped twice rapidly',
      build: buildBloc,
      act: (HomeBloc bloc) => bloc
        ..add(const EntryPressed(HomeEntry.respirar))
        ..add(const EntryPressed(HomeEntry.respirar)),
      expect: () => <Matcher>[
        stateWith(highlightedEntry: HomeEntry.respirar, isNavigating: true),
        stateWith(highlightedEntry: null, isNavigating: false),
      ],
      verify: (_) {
        verify(() => navigator.openRespirar()).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'clears the highlight when navigation fails',
      setUp: () {
        when(() => navigator.openRespirar()).thenAnswer((_) async => throw Exception('boom'));
      },
      build: buildBloc,
      act: (HomeBloc bloc) => bloc.add(const EntryPressed(HomeEntry.respirar)),
      expect: () => <Matcher>[
        stateWith(highlightedEntry: HomeEntry.respirar, isNavigating: true),
        stateWith(highlightedEntry: null, isNavigating: false),
      ],
    );

    test('does not navigate when closed during the highlight', () async {
      final HomeBloc bloc = buildBloc(highlightDuration: const Duration(milliseconds: 50));

      bloc.add(const EntryPressed(HomeEntry.respirar));
      await pumpEventQueue();
      await bloc.close();
      await Future<void>.delayed(const Duration(milliseconds: 80));

      verifyNever(() => navigator.openRespirar());
    });

    test('does not emit after being closed while a module is open', () async {
      final Completer<void> completer = Completer<void>();
      when(() => navigator.openRespirar()).thenAnswer((_) => completer.future);
      final HomeBloc bloc = buildBloc();
      final List<HomeState> states = <HomeState>[];
      final StreamSubscription<HomeState> subscription = bloc.stream.listen(states.add);

      bloc.add(const EntryPressed(HomeEntry.respirar));
      await pumpEventQueue();
      await bloc.close();
      completer.complete();
      await pumpEventQueue();

      expect(states, hasLength(1));
      await subscription.cancel();
    });
  });
}
