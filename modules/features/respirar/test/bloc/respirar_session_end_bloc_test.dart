import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:respirar/src/navigation/respirar_navigator.dart';
import 'package:respirar/src/session_end/bloc/respirar_session_end_bloc.dart';

class _MockGetRandomQuoteUseCase extends Mock implements GetRandomQuoteUseCase {}

class _MockRespirarNavigator extends Mock implements RespirarNavigator {}

const Quote _quote = Quote(
  line: 'Y si un día la suerte,\nque es grela...',
  title: 'Yira, yira',
  year: 1930,
  textId: 'yira_yira',
);

void main() {
  late _MockGetRandomQuoteUseCase getRandomQuote;
  late _MockRespirarNavigator navigator;

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    getRandomQuote = _MockGetRandomQuoteUseCase();
    navigator = _MockRespirarNavigator();
    when(() => getRandomQuote.execute(any())).thenAnswer((_) async => _quote);
    when(() => navigator.openText(any())).thenAnswer((_) async {});
    when(() => navigator.openHome()).thenAnswer((_) async {});
    when(() => navigator.close()).thenAnswer((_) async {});
  });

  RespirarSessionEndBloc buildBloc() {
    return RespirarSessionEndBloc(getRandomQuoteUseCase: getRandomQuote, navigator: navigator);
  }

  Matcher stateWith({
    required bool isLoading,
    required Quote? quote,
    bool isNavigating = false,
    Matcher error = isNull,
  }) {
    return isA<RespirarSessionEndState>()
        .having((RespirarSessionEndState s) => s.isLoading, 'isLoading', isLoading)
        .having((RespirarSessionEndState s) => s.quote, 'quote', quote)
        .having((RespirarSessionEndState s) => s.isNavigating, 'isNavigating', isNavigating)
        .having((RespirarSessionEndState s) => s.error, 'error', error);
  }

  test('initial state is loading without a quote', () {
    final RespirarSessionEndState state = buildBloc().state;

    expect(state.isLoading, isTrue);
    expect(state.quote, isNull);
  });

  group('SessionEndStarted', () {
    blocTest<RespirarSessionEndBloc, RespirarSessionEndState>(
      'loads a random quote',
      build: buildBloc,
      act: (RespirarSessionEndBloc bloc) => bloc.add(const SessionEndStarted()),
      expect: () => <Matcher>[
        stateWith(isLoading: true, quote: null),
        stateWith(isLoading: false, quote: _quote),
      ],
      verify: (_) {
        verify(() => getRandomQuote.execute(any(that: isA<NoParams>()))).called(1);
      },
    );

    blocTest<RespirarSessionEndBloc, RespirarSessionEndState>(
      'shows no quote when none are available',
      setUp: () {
        when(() => getRandomQuote.execute(any())).thenAnswer((_) async => null);
      },
      build: buildBloc,
      act: (RespirarSessionEndBloc bloc) => bloc.add(const SessionEndStarted()),
      expect: () => <Matcher>[
        stateWith(isLoading: true, quote: null),
        stateWith(isLoading: false, quote: null),
      ],
    );

    blocTest<RespirarSessionEndBloc, RespirarSessionEndState>(
      'stores the error and shows no quote when loading fails',
      setUp: () {
        when(() => getRandomQuote.execute(any())).thenThrow(const QuoteLoadException());
      },
      build: buildBloc,
      act: (RespirarSessionEndBloc bloc) => bloc.add(const SessionEndStarted()),
      expect: () => <Matcher>[
        stateWith(isLoading: true, quote: null),
        stateWith(isLoading: false, quote: null, error: isA<QuoteLoadException>()),
      ],
    );

    blocTest<RespirarSessionEndBloc, RespirarSessionEndState>(
      'clears a previous error on a successful reload',
      setUp: () {
        when(() => getRandomQuote.execute(any())).thenThrow(const QuoteLoadException());
      },
      build: buildBloc,
      act: (RespirarSessionEndBloc bloc) async {
        bloc.add(const SessionEndStarted());
        await pumpEventQueue();
        when(() => getRandomQuote.execute(any())).thenAnswer((_) async => _quote);
        bloc.add(const SessionEndStarted());
      },
      skip: 2,
      expect: () => <Matcher>[
        stateWith(isLoading: true, quote: null),
        stateWith(isLoading: false, quote: _quote),
      ],
    );

    test('does not emit when closed while loading', () async {
      final Completer<Quote?> completer = Completer<Quote?>();
      when(() => getRandomQuote.execute(any())).thenAnswer((_) => completer.future);
      final RespirarSessionEndBloc bloc = buildBloc();
      final List<RespirarSessionEndState> states = <RespirarSessionEndState>[];
      final StreamSubscription<RespirarSessionEndState> subscription = bloc.stream.listen(states.add);

      bloc.add(const SessionEndStarted());
      await pumpEventQueue();
      await bloc.close();
      completer.complete(_quote);
      await pumpEventQueue();

      expect(states, hasLength(1));
      await subscription.cancel();
    });
  });

  group('QuotePressed', () {
    blocTest<RespirarSessionEndBloc, RespirarSessionEndState>(
      'opens the full text of the quote',
      build: buildBloc,
      seed: () => const RespirarSessionEndState(isLoading: false, quote: _quote),
      act: (RespirarSessionEndBloc bloc) => bloc.add(const QuotePressed()),
      expect: () => <Matcher>[
        stateWith(isLoading: false, quote: _quote, isNavigating: true),
        stateWith(isLoading: false, quote: _quote),
      ],
      verify: (_) {
        verify(() => navigator.openText('yira_yira')).called(1);
        verifyNoMoreInteractions(navigator);
      },
    );

    blocTest<RespirarSessionEndBloc, RespirarSessionEndState>(
      'does nothing without a quote',
      build: buildBloc,
      seed: () => const RespirarSessionEndState(isLoading: false),
      act: (RespirarSessionEndBloc bloc) => bloc.add(const QuotePressed()),
      expect: () => <Matcher>[],
      verify: (_) {
        verifyZeroInteractions(navigator);
      },
    );

    test('opens the text only once while it is on top', () async {
      final Completer<void> completer = Completer<void>();
      when(() => navigator.openText(any())).thenAnswer((_) => completer.future);
      final RespirarSessionEndBloc bloc = buildBloc();
      bloc.add(const SessionEndStarted());
      await pumpEventQueue();

      bloc
        ..add(const QuotePressed())
        ..add(const QuotePressed())
        ..add(const HomePressed());
      await pumpEventQueue();

      verify(() => navigator.openText('yira_yira')).called(1);
      verifyNever(() => navigator.openHome());
      completer.complete();
      await bloc.close();
    });
  });

  group('HomePressed', () {
    blocTest<RespirarSessionEndBloc, RespirarSessionEndState>(
      'returns to the main screen without opening a text',
      build: buildBloc,
      seed: () => const RespirarSessionEndState(isLoading: false, quote: _quote),
      act: (RespirarSessionEndBloc bloc) => bloc
        ..add(const HomePressed())
        ..add(const HomePressed()),
      expect: () => <Matcher>[
        stateWith(isLoading: false, quote: _quote, isNavigating: true),
      ],
      verify: (_) {
        verify(() => navigator.openHome()).called(1);
        verifyNever(() => navigator.openText(any()));
      },
    );
  });

  group('SessionEndBackPressed', () {
    blocTest<RespirarSessionEndBloc, RespirarSessionEndState>(
      'closes the Respirar flow',
      build: buildBloc,
      seed: () => const RespirarSessionEndState(isLoading: false, quote: _quote),
      act: (RespirarSessionEndBloc bloc) => bloc.add(const SessionEndBackPressed()),
      expect: () => <Matcher>[
        stateWith(isLoading: false, quote: _quote, isNavigating: true),
      ],
      verify: (_) {
        verify(() => navigator.close()).called(1);
        verifyNoMoreInteractions(navigator);
      },
    );
  });
}
