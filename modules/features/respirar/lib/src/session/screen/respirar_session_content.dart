import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../bloc/respirar_session_bloc.dart';
import '../widgets/breathing_point.dart';

class RespirarSessionContent extends StatefulWidget {
  const RespirarSessionContent({super.key});

  @override
  State<RespirarSessionContent> createState() => _RespirarSessionContentState();
}

class _RespirarSessionContentState extends State<RespirarSessionContent> {
  // Just below the breathing point's halo.
  static const Alignment _pausedCaptionAlignment = Alignment(0, 0.45);

  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onHide: _onAppBackgrounded,
      onPause: _onAppBackgrounded,
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  void _onAppBackgrounded() => context.read<RespirarSessionBloc>().add(const AppBackgrounded());

  @override
  Widget build(BuildContext context) {
    final RespirarSessionBloc bloc = context.read<RespirarSessionBloc>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) bloc.add(const ExitRequested());
      },
      child: AppScaffold(
        body: RawGestureDetector(
          behavior: HitTestBehavior.opaque,
          gestures: <Type, GestureRecognizerFactory>{
            TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
              TapGestureRecognizer.new,
              (TapGestureRecognizer recognizer) => recognizer.onTap = () => bloc.add(const ScreenTapped()),
            ),
            LongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
              () => LongPressGestureRecognizer(duration: AppMotions.durationExitHold),
              (LongPressGestureRecognizer recognizer) =>
                  recognizer.onLongPress = () => bloc.add(const ExitRequested()),
            ),
          },
          child: BlocBuilder<RespirarSessionBloc, RespirarSessionState>(
            builder: (BuildContext context, RespirarSessionState state) {
              return Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  BreathingPoint(
                    phaseType: state.phaseType,
                    phaseDuration: state.phaseDuration,
                    phaseNumber: state.phaseNumber,
                    isPaused: state.isPaused,
                    isFinished: state.isFinished,
                  ),
                  Align(
                    alignment: _pausedCaptionAlignment,
                    child: AnimatedOpacity(
                      opacity: state.isPaused && !state.isConfirmingExit ? 1 : 0,
                      duration: AppMotions.durationMedium,
                      curve: AppMotions.standard,
                      child: AppText(
                        text: context.translations.respirar.session.paused,
                        style: context.appTexts.smallCaps,
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
