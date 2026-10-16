import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../bloc/onboarding_bloc.dart';
import '../widgets/onboarding_entry_slide.dart';
import '../widgets/onboarding_intro_slide.dart';
import '../widgets/onboarding_paths_slide.dart';
import '../widgets/onboarding_principles_slide.dart';

class OnboardingContent extends StatefulWidget {
  const OnboardingContent({super.key});

  @override
  State<OnboardingContent> createState() => _OnboardingContentState();
}

class _OnboardingContentState extends State<OnboardingContent> {
  static const int _slideCount = 4;
  static const int _entrySlideIndex = _slideCount - 1;

  int _slideIndex = 0;

  void _showSlide(int index) {
    if (index < 0 || index >= _slideCount || index == _slideIndex) return;
    setState(() => _slideIndex = index);
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final double velocity = details.primaryVelocity ?? 0;
    if (velocity < 0) {
      _showSlide(_slideIndex + 1);
    } else if (velocity > 0) {
      _showSlide(_slideIndex - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final OnboardingBloc bloc = context.read<OnboardingBloc>();
    final AppTranslations t = context.translations;

    return PopScope(
      // Back steps through the slides; only the first slide lets the app close.
      canPop: _slideIndex == 0,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) _showSlide(_slideIndex - 1);
      },
      child: AppScaffold(
        body: BlocBuilder<OnboardingBloc, OnboardingState>(
          builder: (BuildContext context, OnboardingState state) {
            return Stack(
              children: <Widget>[
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _showSlide(_slideIndex + 1),
                    onHorizontalDragEnd: _onHorizontalDragEnd,
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.screenPadding),
                      // Slides crossfade in place; there is no sideways motion.
                      child: AnimatedSwitcher(
                        duration: AppMotions.durationShort,
                        switchInCurve: AppMotions.standard,
                        switchOutCurve: AppMotions.standard,
                        child: SizedBox.expand(
                          key: ValueKey<int>(_slideIndex),
                          child: switch (_slideIndex) {
                            0 => const OnboardingIntroSlide(),
                            1 => const OnboardingPathsSlide(),
                            2 => const OnboardingPrinciplesSlide(),
                            _ => OnboardingEntrySlide(
                              isEnterHighlighted: state.isEnterHighlighted,
                              onEnterPressed: () =>
                                  bloc.add(const EnterPressed()),
                            ),
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppDimens.screenPadding),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: AppTextButton(
                      text: t.onboarding.skip,
                      onPressed: () => bloc.add(const SkipPressed()),
                      style: AppTextButtonStyle.quiet,
                      isEnabled: !state.isCompleting,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.gapL),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: AppDimens.gapS,
                      children: <Widget>[
                        AppProgressDots(count: _slideCount, index: _slideIndex),
                        // Keeps its height on the last slide so the dots do not jump.
                        AnimatedOpacity(
                          opacity: _slideIndex < _entrySlideIndex ? 1 : 0,
                          duration: AppMotions.durationShort,
                          curve: AppMotions.standard,
                          child: IgnorePointer(
                            ignoring: _slideIndex >= _entrySlideIndex,
                            child: AppTextButton(
                              text: t.onboarding.next,
                              onPressed: () => _showSlide(_slideIndex + 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
