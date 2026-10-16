import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

import '../../shared/misc/leer_exception_mapper.dart';

class WordAnnotationCard extends StatelessWidget {
  final LunfardoWord? word;
  final bool isInDictionary;
  final bool isAdding;
  final Exception? error;
  final VoidCallback onAddPressed;
  final VoidCallback onClosePressed;

  const WordAnnotationCard({
    super.key,
    required this.word,
    required this.isInDictionary,
    required this.isAdding,
    required this.error,
    required this.onAddPressed,
    required this.onClosePressed,
  });

  @override
  Widget build(BuildContext context) {
    final AppTranslations t = context.translations;
    final AppTextTheme texts = context.appTexts;
    final AppColorsTheme colors = context.appColors;
    final LunfardoWord? word = this.word;
    final Exception? error = this.error;

    return GestureDetector(
      // Swallows taps on the card so only taps outside it close the popup.
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: ColoredBox(
        color: colors.overlay,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.screenPadding,
              AppDimens.gapXl,
              AppDimens.screenPadding,
              AppDimens.gapL,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (word != null) ...<Widget>[
                  AppText(
                    text: word.word,
                    style: texts.wordHeadline,
                    maxLines: null,
                    color: colors.accent,
                  ),
                  const SizedBox(height: AppDimens.gapS),
                  AppText(
                    text: word.meaning,
                    style: texts.bodyLarge,
                    maxLines: null,
                    color: colors.textPrimary,
                  ),
                  if (word.etymology.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppDimens.gapXs),
                    // One line only (US 12.1); the word card in Hablar shows the whole chain.
                    AppText(
                      text: word.etymology.first,
                      style: texts.caption,
                      color: colors.textSecondary,
                    ),
                  ],
                ],
                if (error != null) ...<Widget>[
                  const SizedBox(height: AppDimens.gapS),
                  AppText(
                    text: LeerExceptionMapper.map(error, t),
                    style: texts.captionSmall,
                    maxLines: null,
                    color: colors.textSecondary,
                  ),
                ],
                const SizedBox(height: AppDimens.gapL),
                Row(
                  children: <Widget>[
                    if (word != null)
                      AppTextButton(
                        text: isInDictionary ? t.leer.annotation.inDictionary : t.leer.annotation.add,
                        onPressed: onAddPressed,
                        isEnabled: !isInDictionary && !isAdding,
                      ),
                    const Spacer(),
                    AppTextButton(
                      text: t.leer.annotation.close,
                      onPressed: onClosePressed,
                      style: AppTextButtonStyle.quiet,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
