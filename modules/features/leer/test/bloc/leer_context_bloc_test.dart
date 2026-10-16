import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leer/src/context/bloc/leer_context_bloc.dart';
import 'package:leer/src/navigation/leer_navigator.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetTextUseCase extends Mock implements GetTextUseCase {}

class _MockLeerNavigator extends Mock implements LeerNavigator {}

const TangoText _text = TangoText(
  id: 'yira_yira',
  title: 'Yira, yira',
  author: 'Enrique Santos Discépolo',
  year: 1930,
  context: 'Argentina after the 1930 coup.',
  stanzas: <TextStanza>[
    TextStanza(
      lines: <TextLine>[
        TextLine(segments: <TextSegment>[TextSegment(text: 'line')]),
      ],
    ),
  ],
);

void main() {
  late _MockGetTextUseCase getText;
  late _MockLeerNavigator navigator;

  setUpAll(() {
    registerFallbackValue(const GetTextParams(textId: ''));
  });

  setUp(() {
    getText = _MockGetTextUseCase();
    navigator = _MockLeerNavigator();
    when(() => getText.execute(any())).thenAnswer((_) async => _text);
    when(() => navigator.startReading(any())).thenAnswer((_) async {});
    when(() => navigator.back()).thenAnswer((_) async {});
  });

  LeerContextBloc buildBloc() => LeerContextBloc(textId: 'yira_yira', getTextUseCase: getText, navigator: navigator);

  Matcher stateWith({
    required bool isLoading,
    TangoText? text,
    bool isNavigating = false,
    Matcher error = isNull,
  }) {
    return isA<LeerContextState>()
        .having((LeerContextState s) => s.isLoading, 'isLoading', isLoading)
        .having((LeerContextState s) => s.text, 'text', text)
        .having((LeerContextState s) => s.isNavigating, 'isNavigating', isNavigating)
        .having((LeerContextState s) => s.error, 'error', error);
  }

  group('ContextStarted', () {
    blocTest<LeerContextBloc, LeerContextState>(
      'loads the requested text',
      build: buildBloc,
      act: (LeerContextBloc bloc) => bloc.add(const ContextStarted()),
      expect: () => <Matcher>[
        stateWith(isLoading: true),
        stateWith(isLoading: false, text: _text),
      ],
      verify: (_) {
        verify(
          () => getText.execute(
            any(that: isA<GetTextParams>().having((GetTextParams p) => p.textId, 'textId', 'yira_yira')),
          ),
        ).called(1);
      },
    );

    blocTest<LeerContextBloc, LeerContextState>(
      'stores the error when the text is missing',
      setUp: () {
        when(() => getText.execute(any())).thenThrow(const TextNotFoundException());
      },
      build: buildBloc,
      act: (LeerContextBloc bloc) => bloc.add(const ContextStarted()),
      expect: () => <Matcher>[
        stateWith(isLoading: true),
        stateWith(isLoading: false, error: isA<TextNotFoundException>()),
      ],
    );

    blocTest<LeerContextBloc, LeerContextState>(
      'clears a previous error on a successful reload',
      setUp: () {
        when(() => getText.execute(any())).thenThrow(const TextLoadException());
      },
      build: buildBloc,
      act: (LeerContextBloc bloc) async {
        bloc.add(const ContextStarted());
        await pumpEventQueue();
        when(() => getText.execute(any())).thenAnswer((_) async => _text);
        bloc.add(const ContextStarted());
      },
      skip: 2,
      expect: () => <Matcher>[
        stateWith(isLoading: true),
        stateWith(isLoading: false, text: _text),
      ],
    );

    test('does not emit when closed while loading', () async {
      final Completer<TangoText> completer = Completer<TangoText>();
      when(() => getText.execute(any())).thenAnswer((_) => completer.future);
      final LeerContextBloc bloc = buildBloc();
      final List<LeerContextState> states = <LeerContextState>[];
      final StreamSubscription<LeerContextState> subscription = bloc.stream.listen(states.add);

      bloc.add(const ContextStarted());
      await pumpEventQueue();
      await bloc.close();
      completer.complete(_text);
      await pumpEventQueue();

      expect(states, hasLength(1));
      await subscription.cancel();
    });
  });

  group('ReadPressed', () {
    blocTest<LeerContextBloc, LeerContextState>(
      'starts reading the loaded text',
      build: buildBloc,
      seed: () => const LeerContextState(isLoading: false, text: _text),
      act: (LeerContextBloc bloc) => bloc.add(const ReadPressed()),
      expect: () => <Matcher>[
        stateWith(isLoading: false, text: _text, isNavigating: true),
        stateWith(isLoading: false, text: _text),
      ],
      verify: (_) {
        verify(() => navigator.startReading('yira_yira')).called(1);
      },
    );

    blocTest<LeerContextBloc, LeerContextState>(
      'does nothing before the text is loaded',
      build: buildBloc,
      act: (LeerContextBloc bloc) => bloc.add(const ReadPressed()),
      expect: () => <Matcher>[],
      verify: (_) {
        verifyNever(() => navigator.startReading(any()));
      },
    );

    blocTest<LeerContextBloc, LeerContextState>(
      'ignores a second tap while navigating',
      setUp: () {
        when(() => navigator.startReading(any())).thenAnswer((_) => Completer<void>().future);
      },
      build: buildBloc,
      seed: () => const LeerContextState(isLoading: false, text: _text),
      act: (LeerContextBloc bloc) {
        bloc
          ..add(const ReadPressed())
          ..add(const ReadPressed());
      },
      expect: () => <Matcher>[
        stateWith(isLoading: false, text: _text, isNavigating: true),
      ],
      verify: (_) {
        verify(() => navigator.startReading('yira_yira')).called(1);
      },
    );
  });

  group('ContextBackPressed', () {
    blocTest<LeerContextBloc, LeerContextState>(
      'goes back to the list',
      build: buildBloc,
      act: (LeerContextBloc bloc) => bloc.add(const ContextBackPressed()),
      expect: () => <Matcher>[],
      verify: (_) {
        verify(() => navigator.back()).called(1);
      },
    );
  });
}
