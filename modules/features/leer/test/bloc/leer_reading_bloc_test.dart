import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leer/src/navigation/leer_navigator.dart';
import 'package:leer/src/reading/bloc/leer_reading_bloc.dart';
import 'package:leer/src/reading/misc/reading_phase.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetTextUseCase extends Mock implements GetTextUseCase {}

class _MockLeerNavigator extends Mock implements LeerNavigator {}

// Mirror the bloc's defaults, AppMotions.silenceStanza and AppMotions.silenceLong (spec: 1 s and 3 s).
const Duration _stanzaPause = Duration(seconds: 1);
const Duration _endSilence = Duration(seconds: 3);
const Duration _justBefore = Duration(milliseconds: 1);

TextLine _line(String text) => TextLine(segments: <TextSegment>[TextSegment(text: text)]);

/// Two stanzas: [uno, dos] and [tres].
final TangoText _text = TangoText(
  id: 'yira_yira',
  title: 'Yira, yira',
  author: 'Enrique Santos Discépolo',
  year: 1930,
  context: 'context',
  stanzas: <TextStanza>[
    TextStanza(lines: <TextLine>[_line('uno'), _line('dos')]),
    TextStanza(lines: <TextLine>[_line('tres')]),
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
    when(() => navigator.openWordAnnotation(any())).thenAnswer((_) async {});
    when(() => navigator.openTextList()).thenAnswer((_) async {});
    when(() => navigator.breatheWithText()).thenAnswer((_) async {});
    when(() => navigator.openHome()).thenAnswer((_) async {});
  });

  LeerReadingBloc buildBloc() {
    return LeerReadingBloc(
      textId: 'yira_yira',
      getTextUseCase: getText,
      navigator: navigator,
    );
  }

  /// Builds a started bloc inside fake time, runs [body], then closes the bloc.
  void runReading(void Function(FakeAsync async, LeerReadingBloc bloc) body) {
    fakeAsync((FakeAsync async) {
      final LeerReadingBloc bloc = buildBloc();
      bloc.add(const ReadingStarted());
      async.flushMicrotasks();

      body(async, bloc);

      unawaited(bloc.close());
      async.flushMicrotasks();
    });
  }

  void tap(FakeAsync async, LeerReadingBloc bloc, {int times = 1}) {
    for (int i = 0; i < times; i++) {
      bloc.add(const ScreenTapped());
      async.flushMicrotasks();
    }
  }

  void expectAt(LeerReadingBloc bloc, {required ReadingPhase phase, int stanza = 0, int line = 0}) {
    expect(bloc.state.phase, phase);
    expect(bloc.state.stanzaIndex, stanza);
    expect(bloc.state.lineIndex, line);
  }

  test('initial state is loading with no line on screen', () {
    final LeerReadingState state = buildBloc().state;

    expect(state.isLoading, isTrue);
    expect(state.text, isNull);
    expect(state.currentLine, isNull);
    expect(state.isEnding, isFalse);
  });

  group('ReadingStarted', () {
    test('loads the text and shows its first line', () {
      runReading((FakeAsync async, LeerReadingBloc bloc) {
        expect(bloc.state.isLoading, isFalse);
        expect(bloc.state.text, same(_text));
        expectAt(bloc, phase: ReadingPhase.line);
        expect(bloc.state.currentLine!.text, 'uno');
        verify(
          () => getText.execute(
            any(that: isA<GetTextParams>().having((GetTextParams p) => p.textId, 'textId', 'yira_yira')),
          ),
        ).called(1);
      });
    });

    blocTest<LeerReadingBloc, LeerReadingState>(
      'stores the error when the text cannot be loaded',
      setUp: () {
        when(() => getText.execute(any())).thenThrow(const TextNotFoundException());
      },
      build: buildBloc,
      act: (LeerReadingBloc bloc) => bloc.add(const ReadingStarted()),
      expect: () => <Matcher>[
        isA<LeerReadingState>().having((LeerReadingState s) => s.isLoading, 'isLoading', isTrue),
        isA<LeerReadingState>()
            .having((LeerReadingState s) => s.isLoading, 'isLoading', isFalse)
            .having((LeerReadingState s) => s.text, 'text', isNull)
            .having((LeerReadingState s) => s.error, 'error', isA<TextNotFoundException>()),
      ],
    );

    test('does not reload once the text is loaded', () {
      runReading((FakeAsync async, LeerReadingBloc bloc) {
        tap(async, bloc);
        bloc.add(const ReadingStarted());
        async.flushMicrotasks();

        expectAt(bloc, phase: ReadingPhase.line, line: 1);
        verify(() => getText.execute(any())).called(1);
      });
    });

    test('does not emit when closed while loading', () async {
      final Completer<TangoText> completer = Completer<TangoText>();
      when(() => getText.execute(any())).thenAnswer((_) => completer.future);
      final LeerReadingBloc bloc = buildBloc();
      final List<LeerReadingState> states = <LeerReadingState>[];
      final StreamSubscription<LeerReadingState> subscription = bloc.stream.listen(states.add);

      bloc.add(const ReadingStarted());
      await pumpEventQueue();
      await bloc.close();
      completer.complete(_text);
      await pumpEventQueue();

      expect(states, hasLength(1));
      await subscription.cancel();
    });
  });

  group('ScreenTapped', () {
    test('reveals the next line of the stanza', () {
      runReading((FakeAsync async, LeerReadingBloc bloc) {
        tap(async, bloc);

        expectAt(bloc, phase: ReadingPhase.line, line: 1);
        expect(bloc.state.currentLine!.text, 'dos');
      });
    });

    test('after the last line of a stanza, stays silent for the stanza pause, then shows the next stanza', () {
      runReading((FakeAsync async, LeerReadingBloc bloc) {
        tap(async, bloc, times: 2);

        expectAt(bloc, phase: ReadingPhase.stanzaPause, line: 1);
        expect(bloc.state.currentLine, isNull);

        async.elapse(_stanzaPause - _justBefore);
        expect(bloc.state.phase, ReadingPhase.stanzaPause);

        async.elapse(_justBefore);
        expectAt(bloc, phase: ReadingPhase.line, stanza: 1);
        expect(bloc.state.currentLine!.text, 'tres');
      });
    });

    test('taps during the stanza pause are ignored, not queued', () {
      runReading((FakeAsync async, LeerReadingBloc bloc) {
        tap(async, bloc, times: 2);
        tap(async, bloc, times: 3);

        async.elapse(_stanzaPause);

        expectAt(bloc, phase: ReadingPhase.line, stanza: 1);
      });
    });

    test('after the last line of the text, stays silent, then shows the end options', () {
      runReading((FakeAsync async, LeerReadingBloc bloc) {
        tap(async, bloc, times: 2);
        async.elapse(_stanzaPause);
        tap(async, bloc);

        expect(bloc.state.phase, ReadingPhase.endSilence);
        expect(bloc.state.isEnding, isTrue);
        expect(bloc.state.currentLine, isNull);

        async.elapse(_endSilence - _justBefore);
        expect(bloc.state.phase, ReadingPhase.endSilence);

        async.elapse(_justBefore);
        expect(bloc.state.phase, ReadingPhase.end);
      });
    });

    test('taps during the end silence and on the end options do nothing', () {
      runReading((FakeAsync async, LeerReadingBloc bloc) {
        tap(async, bloc, times: 2);
        async.elapse(_stanzaPause);
        tap(async, bloc);
        tap(async, bloc, times: 2);
        async.elapse(_endSilence);
        tap(async, bloc, times: 2);

        expectAt(bloc, phase: ReadingPhase.end, stanza: 1);
      });
    });

    test('a one-line text goes straight to the end silence', () {
      when(() => getText.execute(any())).thenAnswer(
        (_) async => TangoText(
          id: 'uno',
          title: 'Uno',
          author: 'Autor',
          year: 1917,
          context: 'context',
          stanzas: <TextStanza>[
            TextStanza(lines: <TextLine>[_line('uno')]),
          ],
        ),
      );

      runReading((FakeAsync async, LeerReadingBloc bloc) {
        tap(async, bloc);

        expect(bloc.state.phase, ReadingPhase.endSilence);
      });
    });

    test('does nothing before the text is loaded', () {
      fakeAsync((FakeAsync async) {
        final LeerReadingBloc bloc = buildBloc();
        bloc.add(const ScreenTapped());
        async.flushMicrotasks();

        expect(bloc.state.isLoading, isTrue);
        expect(bloc.state.lineIndex, 0);

        unawaited(bloc.close());
        async.flushMicrotasks();
      });
    });

    test('closing during a silence cancels its timer', () {
      fakeAsync((FakeAsync async) {
        final LeerReadingBloc bloc = buildBloc();
        bloc.add(const ReadingStarted());
        async.flushMicrotasks();
        tap(async, bloc, times: 2);

        unawaited(bloc.close());
        async.flushMicrotasks();
        async.elapse(_stanzaPause);

        expect(async.pendingTimers, isEmpty);
        expect(bloc.state.phase, ReadingPhase.stanzaPause);
      });
    });
  });

  group('WordPressed', () {
    test('opens the annotation and keeps the same line when it closes', () {
      runReading((FakeAsync async, LeerReadingBloc bloc) {
        // Created inside fake time so its completion is flushed with the fake microtasks.
        final Completer<void> annotation = Completer<void>();
        when(() => navigator.openWordAnnotation(any())).thenAnswer((_) => annotation.future);
        tap(async, bloc);
        bloc.add(const WordPressed('grela'));
        async.flushMicrotasks();

        expect(bloc.state.isNavigating, isTrue);
        verify(() => navigator.openWordAnnotation('grela')).called(1);

        annotation.complete();
        async.flushMicrotasks();

        expect(bloc.state.isNavigating, isFalse);
        expectAt(bloc, phase: ReadingPhase.line, line: 1);
      });
    });

    test('screen taps are ignored while the annotation is open', () {
      final Completer<void> annotation = Completer<void>();
      when(() => navigator.openWordAnnotation(any())).thenAnswer((_) => annotation.future);

      runReading((FakeAsync async, LeerReadingBloc bloc) {
        bloc.add(const WordPressed('grela'));
        async.flushMicrotasks();
        tap(async, bloc);

        expectAt(bloc, phase: ReadingPhase.line);
        annotation.complete();
        async.flushMicrotasks();
      });
    });

    test('a second word tap while the annotation is open is ignored', () {
      final Completer<void> annotation = Completer<void>();
      when(() => navigator.openWordAnnotation(any())).thenAnswer((_) => annotation.future);

      runReading((FakeAsync async, LeerReadingBloc bloc) {
        bloc
          ..add(const WordPressed('grela'))
          ..add(const WordPressed('mina'));
        async.flushMicrotasks();

        verify(() => navigator.openWordAnnotation('grela')).called(1);
        verifyNever(() => navigator.openWordAnnotation('mina'));
        annotation.complete();
        async.flushMicrotasks();
      });
    });

    test('is ignored during a silence', () {
      runReading((FakeAsync async, LeerReadingBloc bloc) {
        tap(async, bloc, times: 2);
        bloc.add(const WordPressed('grela'));
        async.flushMicrotasks();

        verifyNever(() => navigator.openWordAnnotation(any()));
      });
    });

    test('stays usable when navigation fails', () {
      when(() => navigator.openWordAnnotation(any())).thenThrow(Exception('boom'));

      runReading((FakeAsync async, LeerReadingBloc bloc) {
        bloc.add(const WordPressed('grela'));
        async.flushMicrotasks();

        expect(bloc.state.isNavigating, isFalse);
      });
    });
  });

  group('end options', () {
    void reachEnd(FakeAsync async, LeerReadingBloc bloc) {
      tap(async, bloc, times: 2);
      async.elapse(_stanzaPause);
      tap(async, bloc);
      async.elapse(_endSilence);
    }

    test('"Another text" opens the text list', () {
      runReading((FakeAsync async, LeerReadingBloc bloc) {
        reachEnd(async, bloc);
        bloc.add(const AnotherTextPressed());
        async.flushMicrotasks();

        verify(() => navigator.openTextList()).called(1);
      });
    });

    test('"Breathe with this text" opens Respirar and is usable again on return', () {
      runReading((FakeAsync async, LeerReadingBloc bloc) {
        final Completer<void> breathing = Completer<void>();
        when(() => navigator.breatheWithText()).thenAnswer((_) => breathing.future);
        reachEnd(async, bloc);
        bloc.add(const BreathePressed());
        async.flushMicrotasks();

        expect(bloc.state.isNavigating, isTrue);
        verify(() => navigator.breatheWithText()).called(1);

        breathing.complete();
        async.flushMicrotasks();

        expect(bloc.state.isNavigating, isFalse);
        expect(bloc.state.phase, ReadingPhase.end);
      });
    });

    test('"Home" opens the main screen', () {
      runReading((FakeAsync async, LeerReadingBloc bloc) {
        reachEnd(async, bloc);
        bloc.add(const HomePressed());
        async.flushMicrotasks();

        verify(() => navigator.openHome()).called(1);
      });
    });

    test('a second option tap while navigating is ignored', () {
      when(() => navigator.breatheWithText()).thenAnswer((_) => Completer<void>().future);

      runReading((FakeAsync async, LeerReadingBloc bloc) {
        reachEnd(async, bloc);
        bloc
          ..add(const BreathePressed())
          ..add(const HomePressed());
        async.flushMicrotasks();

        verify(() => navigator.breatheWithText()).called(1);
        verifyNever(() => navigator.openHome());
      });
    });

    test('options are ignored before the end', () {
      runReading((FakeAsync async, LeerReadingBloc bloc) {
        bloc
          ..add(const AnotherTextPressed())
          ..add(const BreathePressed())
          ..add(const HomePressed());
        async.flushMicrotasks();

        verifyNever(() => navigator.openTextList());
        verifyNever(() => navigator.breatheWithText());
        verifyNever(() => navigator.openHome());
      });
    });

    test('stays usable when navigation fails', () {
      when(() => navigator.openHome()).thenThrow(Exception('boom'));

      runReading((FakeAsync async, LeerReadingBloc bloc) {
        reachEnd(async, bloc);
        bloc.add(const HomePressed());
        async.flushMicrotasks();

        expect(bloc.state.isNavigating, isFalse);
      });
    });
  });

  group('TextEndBackPressed', () {
    test('opens the text list from the end options', () {
      runReading((FakeAsync async, LeerReadingBloc bloc) {
        tap(async, bloc, times: 2);
        async.elapse(_stanzaPause);
        tap(async, bloc);
        async.elapse(_endSilence);

        bloc.add(const TextEndBackPressed());
        async.flushMicrotasks();

        expect(bloc.state.isNavigating, isTrue);
        verify(() => navigator.openTextList()).called(1);
      });
    });

    test('opens the text list during the end silence and stops the silence', () {
      runReading((FakeAsync async, LeerReadingBloc bloc) {
        tap(async, bloc, times: 2);
        async.elapse(_stanzaPause);
        tap(async, bloc);

        bloc.add(const TextEndBackPressed());
        async.flushMicrotasks();
        async.elapse(_endSilence);

        verify(() => navigator.openTextList()).called(1);
        expect(bloc.state.phase, ReadingPhase.endSilence);
      });
    });

    test('is ignored while reading', () {
      runReading((FakeAsync async, LeerReadingBloc bloc) {
        bloc.add(const TextEndBackPressed());
        async.flushMicrotasks();

        verifyNever(() => navigator.openTextList());
        expect(bloc.state.isNavigating, isFalse);
      });
    });
  });
}
