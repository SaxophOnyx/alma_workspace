import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../shared/misc/leer_exception_mapper.dart';
import '../bloc/leer_reading_bloc.dart';
import '../misc/reading_phase.dart';
import '../widgets/reading_line.dart';
import '../widgets/text_end_options.dart';

class LeerReadingContent extends StatelessWidget {
  static const ValueKey<String> _silenceKey = ValueKey<String>('silence');
  static const ValueKey<String> _endKey = ValueKey<String>('end');
  static const ValueKey<String> _errorKey = ValueKey<String>('error');

  const LeerReadingContent({super.key});

  @override
  Widget build(BuildContext context) {
    final LeerReadingBloc bloc = context.read<LeerReadingBloc>();
    final AppTranslations t = context.translations;

    final Widget scaffold = AppScaffold(
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => bloc.add(const ScreenTapped()),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.screenPadding),
            child: Center(
              child: BlocBuilder<LeerReadingBloc, LeerReadingState>(
                buildWhen: (LeerReadingState previous, LeerReadingState current) =>
                    previous.isLoading != current.isLoading ||
                    previous.phase != current.phase ||
                    previous.stanzaIndex != current.stanzaIndex ||
                    previous.lineIndex != current.lineIndex ||
                    previous.error != current.error,
                builder: (BuildContext context, LeerReadingState state) {
                  final Exception? error = state.error;

                  return AnimatedSwitcher(
                    duration: AppMotions.durationShort,
                    switchInCurve: AppMotions.standard,
                    switchOutCurve: AppMotions.standard,
                    child: switch (state.currentLine) {
                      _ when error != null => AppText(
                        key: _errorKey,
                        text: LeerExceptionMapper.map(error, t),
                        style: context.appTexts.body,
                        maxLines: null,
                        textAlign: TextAlign.center,
                        color: context.appColors.textSecondary,
                      ),
                      _ when state.phase == ReadingPhase.end => TextEndOptions(
                        key: _endKey,
                        onAnotherTextPressed: () => bloc.add(const AnotherTextPressed()),
                        onBreathePressed: () => bloc.add(const BreathePressed()),
                        onHomePressed: () => bloc.add(const HomePressed()),
                      ),
                      final TextLine line => ReadingLine(
                        key: ValueKey<String>('${state.stanzaIndex}:${state.lineIndex}'),
                        line: line,
                        onWordPressed: (String wordId) => bloc.add(WordPressed(wordId)),
                      ),
                      null => const SizedBox.shrink(key: _silenceKey),
                    },
                  );
                },
              ),
            ),
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
