import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class BreathingPoint extends StatefulWidget {
  final BreathingPhaseType? phaseType;
  final Duration phaseDuration;
  final int phaseNumber;
  final bool isPaused;
  final bool isFinished;

  const BreathingPoint({
    super.key,
    required this.phaseType,
    required this.phaseDuration,
    required this.phaseNumber,
    required this.isPaused,
    required this.isFinished,
  });

  @override
  State<BreathingPoint> createState() => _BreathingPointState();
}

class _BreathingPointState extends State<BreathingPoint> with TickerProviderStateMixin {
  // Radial gradient stops from the palette spec: Crema center, Oro at 60%, Oro fading to 0%.
  static const double _middleAccentOpacity = 0.6;
  static const double _middleStop = 0.5;

  // The halo is the same light spread wide and faint, so the point reads as a glow, not a disc.
  static const double _haloAccentOpacity = 0.14;

  // A hold is frozen in size; only the light breathes, like a candle.
  static const double _flickerDepth = 0.06;
  static const double _pausedOpacity = 0.4;

  late final AnimationController _controller;
  late final CurvedAnimation _curve;
  late final AnimationController _flickerController;
  late final Animation<double> _flicker;
  Animation<double> _diameter = const AlwaysStoppedAnimation<double>(AppDimens.breathingPointRest);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _curve = CurvedAnimation(parent: _controller, curve: AppMotions.standard);
    _flickerController = AnimationController(vsync: this, duration: AppMotions.flicker);
    _flicker = Tween<double>(begin: 1, end: 1 - _flickerDepth).animate(
      CurvedAnimation(parent: _flickerController, curve: AppMotions.standard),
    );
    if (widget.phaseType != null) _startPhase();
  }

  @override
  void didUpdateWidget(BreathingPoint oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.phaseNumber != oldWidget.phaseNumber && widget.phaseType != null) {
      _startPhase();
    } else if (widget.isPaused != oldWidget.isPaused) {
      if (widget.isPaused) {
        _controller.stop();
      } else if (!_controller.isCompleted) {
        _controller.forward();
      }
    }
    _updateFlicker();
  }

  void _updateFlicker() {
    final bool isHolding = widget.phaseType == BreathingPhaseType.hold && !widget.isPaused && !widget.isFinished;
    if (isHolding && !_flickerController.isAnimating) {
      _flickerController.repeat(reverse: true);
    } else if (!isHolding && _flickerController.value != 0) {
      _flickerController.animateBack(0);
    }
  }

  @override
  void dispose() {
    _flickerController.dispose();
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _startPhase() {
    final double current = _diameter.value;
    final double target = switch (widget.phaseType!) {
      BreathingPhaseType.inhale => AppDimens.breathingPointMax,
      BreathingPhaseType.exhale => AppDimens.breathingPointMin,
      BreathingPhaseType.hold => current,
    };

    _diameter = Tween<double>(begin: current, end: target).animate(_curve);
    _controller.duration = widget.phaseDuration;
    _controller.value = 0;
    if (!widget.isPaused) _controller.forward();
    _updateFlicker();
  }

  @override
  Widget build(BuildContext context) {
    final AppColorsTheme colors = context.appColors;

    return AnimatedOpacity(
      opacity: widget.isFinished ? 0 : 1,
      duration: AppMotions.durationFadeOut,
      curve: AppMotions.standard,
      child: AnimatedOpacity(
        opacity: widget.isPaused ? _pausedOpacity : 1,
        duration: AppMotions.durationMedium,
        curve: AppMotions.standard,
        // Reserve the largest halo so the point grows in place without shifting the layout.
        child: SizedBox.square(
          dimension: AppDimens.breathingPointMax * AppDimens.breathingHaloScale,
          child: FadeTransition(
            opacity: _flicker,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget? child) {
                final double diameter = _diameter.value;
                return Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SizedBox.square(
                      dimension: diameter * AppDimens.breathingHaloScale,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: <Color>[
                              colors.accent.withValues(alpha: _haloAccentOpacity),
                              colors.accent.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox.square(
                      dimension: diameter,
                      child: child,
                    ),
                  ],
                );
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[
                      colors.textPrimary,
                      colors.accent.withValues(alpha: _middleAccentOpacity),
                      colors.accent.withValues(alpha: 0),
                    ],
                    stops: const <double>[0, _middleStop, 1],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
