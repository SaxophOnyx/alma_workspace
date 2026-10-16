import 'dart:async';

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
  static const int _pathsSlideIndex = 1;
  static const int _entrySlideIndex = 3;

  late final PageController _pageController;
  int _currentSlideIndex = 0;
  bool _arePathsRevealed = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSlideChanged(int index) {
    setState(() {
      _currentSlideIndex = index;
      if (index == _pathsSlideIndex) {
        _arePathsRevealed = true;
      }
    });
  }

  void _onBackgroundTap() {
    if (_currentSlideIndex >= _entrySlideIndex) return;
    unawaited(
      _pageController.nextPage(
        duration: AppMotions.durationShort,
        curve: AppMotions.standard,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final OnboardingBloc bloc = context.read<OnboardingBloc>();

    return AppScaffold(
      body: BlocBuilder<OnboardingBloc, OnboardingState>(
        builder: (BuildContext context, OnboardingState state) {
          return Stack(
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _onBackgroundTap,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onSlideChanged,
                  // Padding lives inside each page so slides travel edge to edge while swiping.
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(AppDimens.screenPadding),
                      child: OnboardingIntroSlide(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppDimens.screenPadding),
                      child: OnboardingPathsSlide(isRevealed: _arePathsRevealed),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(AppDimens.screenPadding),
                      child: OnboardingPrinciplesSlide(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppDimens.screenPadding),
                      child: OnboardingEntrySlide(
                        isEnterHighlighted: state.isEnterHighlighted,
                        onEnterPressed: () => bloc.add(const EnterPressed()),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimens.screenPadding),
                child: Align(
                  alignment: Alignment.topRight,
                  child: AppTextButton(
                    text: context.translations.onboarding.skip,
                    onPressed: () => bloc.add(const SkipPressed()),
                    isEnabled: !state.isCompleting,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
