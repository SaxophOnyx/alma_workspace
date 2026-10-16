import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:respirar/src/modes/bloc/respirar_modes_bloc.dart';
import 'package:respirar/src/navigation/respirar_navigator.dart';

class _MockRespirarNavigator extends Mock implements RespirarNavigator {}

void main() {
  late _MockRespirarNavigator navigator;

  setUpAll(() {
    registerFallbackValue(BreathingMode.compas);
  });

  setUp(() {
    navigator = _MockRespirarNavigator();
    when(() => navigator.openDurationSelection(any())).thenAnswer((_) async {});
    when(() => navigator.back()).thenAnswer((_) async {});
  });

  RespirarModesBloc buildBloc() => RespirarModesBloc(navigator: navigator);

  Matcher stateWith({required bool isNavigating}) {
    return isA<RespirarModesState>().having((RespirarModesState s) => s.isNavigating, 'isNavigating', isNavigating);
  }

  group('ModeSelected', () {
    for (final BreathingMode mode in BreathingMode.values) {
      blocTest<RespirarModesBloc, RespirarModesState>(
        'opens duration selection for ${mode.name}',
        build: buildBloc,
        act: (RespirarModesBloc bloc) => bloc.add(ModeSelected(mode)),
        expect: () => <Matcher>[
          stateWith(isNavigating: true),
          stateWith(isNavigating: false),
        ],
        verify: (_) {
          verify(() => navigator.openDurationSelection(mode)).called(1);
          verifyNoMoreInteractions(navigator);
        },
      );
    }

    test('ignores further taps until the duration screen pops back', () async {
      final Completer<void> completer = Completer<void>();
      when(() => navigator.openDurationSelection(any())).thenAnswer((_) => completer.future);
      final RespirarModesBloc bloc = buildBloc();

      bloc
        ..add(const ModeSelected(BreathingMode.compas))
        ..add(const ModeSelected(BreathingMode.abrazo));
      await pumpEventQueue();
      expect(bloc.state.isNavigating, isTrue);

      completer.complete();
      await pumpEventQueue();
      expect(bloc.state.isNavigating, isFalse);
      verify(() => navigator.openDurationSelection(BreathingMode.compas)).called(1);
      verifyNever(() => navigator.openDurationSelection(BreathingMode.abrazo));

      await bloc.close();
    });

    blocTest<RespirarModesBloc, RespirarModesState>(
      'becomes usable again when navigation fails',
      setUp: () {
        when(() => navigator.openDurationSelection(any())).thenAnswer((_) async => throw Exception('boom'));
      },
      build: buildBloc,
      act: (RespirarModesBloc bloc) => bloc.add(const ModeSelected(BreathingMode.pausa)),
      expect: () => <Matcher>[
        stateWith(isNavigating: true),
        stateWith(isNavigating: false),
      ],
    );

    test('does not emit when closed while the duration screen is open', () async {
      final Completer<void> completer = Completer<void>();
      when(() => navigator.openDurationSelection(any())).thenAnswer((_) => completer.future);
      final RespirarModesBloc bloc = buildBloc();
      final List<RespirarModesState> states = <RespirarModesState>[];
      final StreamSubscription<RespirarModesState> subscription = bloc.stream.listen(states.add);

      bloc.add(const ModeSelected(BreathingMode.caminar));
      await pumpEventQueue();
      await bloc.close();
      completer.complete();
      await pumpEventQueue();

      expect(states, hasLength(1));
      await subscription.cancel();
    });
  });

  group('ModesBackPressed', () {
    blocTest<RespirarModesBloc, RespirarModesState>(
      'navigates back',
      build: buildBloc,
      act: (RespirarModesBloc bloc) => bloc.add(const ModesBackPressed()),
      expect: () => <Matcher>[],
      verify: (_) {
        verify(() => navigator.back()).called(1);
        verifyNoMoreInteractions(navigator);
      },
    );
  });
}
