import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../bloc/respirar_session_end_bloc.dart';
import '../widgets/session_end_quote.dart';

class RespirarSessionEndContent extends StatelessWidget {
  const RespirarSessionEndContent({super.key});

  @override
  Widget build(BuildContext context) {
    final RespirarSessionEndBloc bloc = context.read<RespirarSessionEndBloc>();
    final AppTranslations t = context.translations;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) bloc.add(const SessionEndBackPressed());
      },
      child: AppScaffold(
        body: Padding(
          padding: const EdgeInsets.all(AppDimens.screenPadding),
          child: Center(
            child: BlocBuilder<RespirarSessionEndBloc, RespirarSessionEndState>(
              buildWhen: (RespirarSessionEndState previous, RespirarSessionEndState current) =>
                  previous.isLoading != current.isLoading || previous.quote != current.quote,
              builder: (BuildContext context, RespirarSessionEndState state) {
                if (state.isLoading) return const SizedBox.shrink();

                final Quote? quote = state.quote;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (quote != null) ...<Widget>[
                      AppFadeIn(
                        delay: AppMotions.silenceShort,
                        duration: AppMotions.durationQuoteFadeIn,
                        child: SessionEndQuote(
                          quote: quote,
                          onPressed: () => bloc.add(const QuotePressed()),
                        ),
                      ),
                      const SizedBox(height: AppDimens.gapL),
                      AppFadeIn(
                        delay: AppMotions.silenceShort + AppMotions.staggerInterval,
                        duration: AppMotions.durationQuoteFadeIn,
                        child: AppText(
                          text: t.respirar.end.source(title: quote.title, year: quote.year),
                          style: context.appTexts.captionSmall,
                          textAlign: TextAlign.center,
                          color: context.appColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimens.gapXxl),
                    ],
                    AppFadeIn(
                      delay: AppMotions.silenceShort + AppMotions.staggerInterval * 2,
                      duration: AppMotions.durationQuoteFadeIn,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: AppDimens.gapS,
                        children: <Widget>[
                          if (quote != null)
                            AppTextButton(
                              text: t.respirar.end.readFullText,
                              onPressed: () => bloc.add(const QuotePressed()),
                            ),
                          AppTextButton(
                            text: t.respirar.end.home,
                            onPressed: () => bloc.add(const HomePressed()),
                            style: AppTextButtonStyle.quiet,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
