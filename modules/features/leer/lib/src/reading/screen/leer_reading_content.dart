import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../shared/misc/leer_exception_mapper.dart';
import '../bloc/leer_reading_bloc.dart';
import '../misc/reading_phase.dart';
import '../widgets/reading_stanza.dart';
import '../widgets/text_end_options.dart';

class LeerReadingContent extends StatelessWidget {
  const LeerReadingContent({super.key});

  @override
  Widget build(BuildContext context) {
    final LeerReadingBloc bloc = context.read<LeerReadingBloc>();

    final Widget scaffold = AppScaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => bloc.add(const ScreenTapped()),
        child: BlocBuilder<LeerReadingBloc, LeerReadingState>(
          buildWhen: (LeerReadingState previous, LeerReadingState current) =>
              previous.isLoading != current.isLoading ||
              previous.phase != current.phase ||
              previous.stanzaIndex != current.stanzaIndex ||
              previous.lineIndex != current.lineIndex ||
              previous.activeWordId != current.activeWordId ||
              previous.error != current.error,
          builder: (BuildContext context, LeerReadingState state) {
            return Stack(
              children: <Widget>[
                Positioned.fill(
                  child: _ReadingBody(state: state),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _ReadingFooter(state: state),
                ),
              ],
            );
          },
        ),
      ),
    );

    return BlocBuilder<LeerReadingBloc, LeerReadingState>(
      buildWhen: (LeerReadingState previous, LeerReadingState current) => previous.isEnding != current.isEnding,
      builder: (BuildContext context, LeerReadingState state) {
        return PopScope(
          // Back from the text end leads to the text list, not the context card.
          canPop: !state.isEnding,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (!didPop) bloc.add(const TextEndBackPressed());
          },
          child: scaffold,
        );
      },
    );
  }
}

class _ReadingBody extends StatelessWidget {
  static const ValueKey<String> _silenceKey = ValueKey<String>('silence');

  final LeerReadingState state;

  const _ReadingBody({
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final LeerReadingBloc bloc = context.read<LeerReadingBloc>();
    final Exception? error = state.error;
    final TangoText? text = state.text;

    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        child: Center(
          child: AppText(
            text: LeerExceptionMapper.map(error, context.translations),
            style: context.appTexts.body,
            maxLines: null,
            textAlign: TextAlign.center,
            color: context.appColors.textSecondary,
          ),
        ),
      );
    }
    if (state.phase == ReadingPhase.end) {
      return Center(
        child: TextEndOptions(
          onAnotherTextPressed: () => bloc.add(const AnotherTextPressed()),
          onBreathePressed: () => bloc.add(const BreathePressed()),
          onHomePressed: () => bloc.add(const HomePressed()),
        ),
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppDimens.screenPadding,
            constraints.maxHeight * AppDimens.readingTopFraction,
            AppDimens.screenPadding,
            AppDimens.gapXxl,
          ),
          child: AnimatedSwitcher(
            duration: AppMotions.durationShort,
            switchInCurve: AppMotions.standard,
            switchOutCurve: AppMotions.standard,
            // A stanza grows downward from the same spot instead of re-centering with every line.
            layoutBuilder: (Widget? current, List<Widget> previous) => Stack(
              alignment: Alignment.topLeft,
              children: <Widget>[...previous, ?current],
            ),
            child: text != null && state.phase == ReadingPhase.line
                ? ReadingStanza(
                    key: ValueKey<int>(state.stanzaIndex),
                    stanza: text.stanzas[state.stanzaIndex],
                    lineIndex: state.lineIndex,
                    activeWordId: state.activeWordId,
                    onWordPressed: (String wordId) => bloc.add(WordPressed(wordId)),
                  )
                : const SizedBox.shrink(key: _silenceKey),
          ),
        );
      },
    );
  }
}

/// A hint on the very first line, and a dot per stanza while reading.
class _ReadingFooter extends StatelessWidget {
  final LeerReadingState state;

  const _ReadingFooter({
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final TangoText? text = state.text;
    // Hidden under an open annotation so it does not show through the popup.
    final bool isReading = text != null && state.error == null && !state.isEnding && state.activeWordId == null;
    final bool isFirstLine = state.phase == ReadingPhase.line && state.stanzaIndex == 0 && state.lineIndex == 0;

    return AnimatedOpacity(
      opacity: isReading ? 1 : 0,
      duration: AppMotions.durationMedium,
      curve: AppMotions.standard,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppDimens.gapXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppDimens.gapM,
          children: <Widget>[
            AnimatedOpacity(
              opacity: isReading && isFirstLine ? 1 : 0,
              duration: AppMotions.durationMedium,
              curve: AppMotions.standard,
              child: AppText(
                text: context.translations.leer.reading.hint,
                style: context.appTexts.smallCaps,
                color: context.appColors.textSecondary,
              ),
            ),
            if (text != null) AppProgressDots(count: text.stanzas.length, index: state.stanzaIndex),
          ],
        ),
      ),
    );
  }
}
