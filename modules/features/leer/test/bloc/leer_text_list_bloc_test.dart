import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leer/src/navigation/leer_navigator.dart';
import 'package:leer/src/text_list/bloc/leer_text_list_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetTextsUseCase extends Mock implements GetTextsUseCase {}

class _MockLeerNavigator extends Mock implements LeerNavigator {}

TangoText _text(String id, int year) {
  return TangoText(
    id: id,
    title: id,
    author: 'Autor',
    year: year,
    context: 'context',
    stanzas: const <TextStanza>[
      TextStanza(
        lines: <TextLine>[
          TextLine(segments: <TextSegment>[TextSegment(text: 'line')]),
        ],
      ),
    ],
  );
}

final List<TangoText> _texts = <TangoText>[_text('yira_yira', 1930), _text('mi_noche_triste', 1917)];

void main() {
  late _MockGetTextsUseCase getTexts;
  late _MockLeerNavigator navigator;

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    getTexts = _MockGetTextsUseCase();
    navigator = _MockLeerNavigator();
    when(() => getTexts.execute(any())).thenAnswer((_) async => _texts);
    when(() => navigator.openContext(any())).thenAnswer((_) async {});
    when(() => navigator.back()).thenAnswer((_) async {});
  });

  LeerTextListBloc buildBloc() => LeerTextListBloc(getTextsUseCase: getTexts, navigator: navigator);

  Matcher stateWith({
    required bool isLoading,
    List<TangoText> texts = const <TangoText>[],
    bool isNavigating = false,
    Matcher error = isNull,
  }) {
    return isA<LeerTextListState>()
        .having((LeerTextListState s) => s.isLoading, 'isLoading', isLoading)
        .having((LeerTextListState s) => s.texts, 'texts', texts)
        .having((LeerTextListState s) => s.isNavigating, 'isNavigating', isNavigating)
        .having((LeerTextListState s) => s.error, 'error', error);
  }

  test('initial state is loading with no texts', () {
    final LeerTextListState state = buildBloc().state;

    expect(state.isLoading, isTrue);
    expect(state.texts, isEmpty);
    expect(state.error, isNull);
  });

  group('TextListStarted', () {
    blocTest<LeerTextListBloc, LeerTextListState>(
      'loads the texts in content order',
      build: buildBloc,
      act: (LeerTextListBloc bloc) => bloc.add(const TextListStarted()),
      expect: () => <Matcher>[
        stateWith(isLoading: true),
        stateWith(isLoading: false, texts: _texts),
      ],
      verify: (_) {
        verify(() => getTexts.execute(any(that: isA<NoParams>()))).called(1);
      },
    );

    blocTest<LeerTextListBloc, LeerTextListState>(
      'stores the error when loading fails',
      setUp: () {
        when(() => getTexts.execute(any())).thenThrow(const TextLoadException());
      },
      build: buildBloc,
      act: (LeerTextListBloc bloc) => bloc.add(const TextListStarted()),
      expect: () => <Matcher>[
        stateWith(isLoading: true),
        stateWith(isLoading: false, error: isA<TextLoadException>()),
      ],
    );

    blocTest<LeerTextListBloc, LeerTextListState>(
      'clears a previous error on a successful reload',
      setUp: () {
        when(() => getTexts.execute(any())).thenThrow(const TextLoadException());
      },
      build: buildBloc,
      act: (LeerTextListBloc bloc) async {
        bloc.add(const TextListStarted());
        await pumpEventQueue();
        when(() => getTexts.execute(any())).thenAnswer((_) async => _texts);
        bloc.add(const TextListStarted());
      },
      skip: 2,
      expect: () => <Matcher>[
        stateWith(isLoading: true),
        stateWith(isLoading: false, texts: _texts),
      ],
    );

    test('does not emit when closed while loading', () async {
      final Completer<List<TangoText>> completer = Completer<List<TangoText>>();
      when(() => getTexts.execute(any())).thenAnswer((_) => completer.future);
      final LeerTextListBloc bloc = buildBloc();
      final List<LeerTextListState> states = <LeerTextListState>[];
      final StreamSubscription<LeerTextListState> subscription = bloc.stream.listen(states.add);

      bloc.add(const TextListStarted());
      await pumpEventQueue();
      await bloc.close();
      completer.complete(_texts);
      await pumpEventQueue();

      expect(states, hasLength(1));
      await subscription.cancel();
    });
  });

  group('TextPressed', () {
    blocTest<LeerTextListBloc, LeerTextListState>(
      'opens the context card for the text',
      build: buildBloc,
      seed: () => LeerTextListState(isLoading: false, texts: _texts),
      act: (LeerTextListBloc bloc) => bloc.add(const TextPressed('yira_yira')),
      expect: () => <Matcher>[
        stateWith(isLoading: false, texts: _texts, isNavigating: true),
        stateWith(isLoading: false, texts: _texts),
      ],
      verify: (_) {
        verify(() => navigator.openContext('yira_yira')).called(1);
      },
    );

    blocTest<LeerTextListBloc, LeerTextListState>(
      'ignores a second tap while navigating',
      setUp: () {
        when(() => navigator.openContext(any())).thenAnswer((_) => Completer<void>().future);
      },
      build: buildBloc,
      seed: () => LeerTextListState(isLoading: false, texts: _texts),
      act: (LeerTextListBloc bloc) {
        bloc
          ..add(const TextPressed('yira_yira'))
          ..add(const TextPressed('mi_noche_triste'));
      },
      expect: () => <Matcher>[
        stateWith(isLoading: false, texts: _texts, isNavigating: true),
      ],
      verify: (_) {
        verify(() => navigator.openContext('yira_yira')).called(1);
        verifyNever(() => navigator.openContext('mi_noche_triste'));
      },
    );

    blocTest<LeerTextListBloc, LeerTextListState>(
      'stays usable when navigation fails',
      setUp: () {
        when(() => navigator.openContext(any())).thenThrow(Exception('boom'));
      },
      build: buildBloc,
      seed: () => LeerTextListState(isLoading: false, texts: _texts),
      act: (LeerTextListBloc bloc) => bloc.add(const TextPressed('yira_yira')),
      expect: () => <Matcher>[
        stateWith(isLoading: false, texts: _texts, isNavigating: true),
        stateWith(isLoading: false, texts: _texts),
      ],
    );
  });

  group('TextListBackPressed', () {
    blocTest<LeerTextListBloc, LeerTextListState>(
      'goes back',
      build: buildBloc,
      act: (LeerTextListBloc bloc) => bloc.add(const TextListBackPressed()),
      expect: () => <Matcher>[],
      verify: (_) {
        verify(() => navigator.back()).called(1);
      },
    );

    blocTest<LeerTextListBloc, LeerTextListState>(
      'does nothing while navigating',
      build: buildBloc,
      seed: () => const LeerTextListState(isNavigating: true),
      act: (LeerTextListBloc bloc) => bloc.add(const TextListBackPressed()),
      expect: () => <Matcher>[],
      verify: (_) {
        verifyNever(() => navigator.back());
      },
    );
  });
}
