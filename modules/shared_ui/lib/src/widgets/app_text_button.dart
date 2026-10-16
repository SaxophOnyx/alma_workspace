import 'dart:async';

import 'package:flutter/material.dart';

import '../../shared_ui.dart';

enum AppTextButtonStyle {
  navigation,
  title,
  menu,
  action,
  quiet,
  signal,
  back,
}

/// A word that acts as a button: it glows Oro on press and holds the glow briefly before acting,
/// so every tap is seen to land.
class AppTextButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final AppTextButtonStyle style;
  final bool isHighlighted;
  final bool isEnabled;
  final String? semanticLabel;

  const AppTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.style = AppTextButtonStyle.action,
    this.isHighlighted = false,
    this.isEnabled = true,
    this.semanticLabel,
  });

  @override
  State<AppTextButton> createState() => _AppTextButtonState();
}

class _AppTextButtonState extends State<AppTextButton> {
  final WidgetStatesController _statesController = WidgetStatesController();
  Timer? _actionTimer;

  bool get _isActivating => _actionTimer?.isActive ?? false;

  @override
  void dispose() {
    _actionTimer?.cancel();
    _statesController.dispose();
    super.dispose();
  }

  void _onPressed() {
    if (_isActivating) return;
    setState(() {
      _actionTimer = Timer(AppMotions.durationHighlight, _onHighlightShown);
    });
  }

  void _onHighlightShown() {
    if (!mounted) return;
    setState(() {});
    widget.onPressed();
  }

  Color _resolveColor(AppColorsTheme colors, Set<WidgetState> states) {
    if (!widget.isEnabled) return colors.textSecondary;
    if (widget.style == AppTextButtonStyle.signal) return colors.signal;
    if (widget.isHighlighted || _isActivating || states.contains(WidgetState.pressed)) return colors.accent;
    return switch (widget.style) {
      AppTextButtonStyle.quiet || AppTextButtonStyle.back => colors.textSecondary,
      _ => colors.textPrimary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final AppColorsTheme colors = context.appColors;
    final AppTextTheme texts = context.appTexts;
    final TextStyle textStyle = switch (widget.style) {
      AppTextButtonStyle.navigation || AppTextButtonStyle.back => texts.navigation,
      AppTextButtonStyle.title => texts.title,
      AppTextButtonStyle.menu => texts.menu,
      AppTextButtonStyle.action || AppTextButtonStyle.signal => texts.action,
      AppTextButtonStyle.quiet => texts.smallCaps,
    };

    return TextButton(
      onPressed: widget.isEnabled ? _onPressed : null,
      statesController: _statesController,
      style: ButtonStyle(
        overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        minimumSize: const WidgetStatePropertyAll<Size>(
          Size(AppDimens.minTouchTarget, AppDimens.minTouchTarget),
        ),
        // No inset, so a left-aligned button lines up with the text column above it.
        padding: const WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.zero),
        alignment: widget.style == AppTextButtonStyle.back ? Alignment.centerLeft : Alignment.center,
      ),
      child: Semantics(
        label: widget.semanticLabel,
        excludeSemantics: widget.semanticLabel != null,
        child: ValueListenableBuilder<Set<WidgetState>>(
          valueListenable: _statesController,
          builder: (BuildContext context, Set<WidgetState> states, Widget? child) {
            return AnimatedDefaultTextStyle(
              style: textStyle.copyWith(color: _resolveColor(colors, states)),
              duration: AppMotions.durationHighlight,
              curve: AppMotions.standard,
              child: child!,
            );
          },
          child: AnimatedSwitcher(
            duration: AppMotions.durationShort,
            switchInCurve: AppMotions.standard,
            switchOutCurve: AppMotions.standard,
            child: AppText(
              key: ValueKey<String>(widget.text),
              text: widget.text,
              style: textStyle,
              maxLines: null,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
