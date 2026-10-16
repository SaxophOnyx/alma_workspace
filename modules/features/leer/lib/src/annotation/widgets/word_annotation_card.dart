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
      child: DecoratedBox(
        decoration: BoxDecoration(color: colors.overlay),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimens.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (word != null) ...<Widget>[
                AppText(
                  text: word.word,
                  style: texts.title,
                  maxLines: null,
                  color: colors.accent,
                ),
                const SizedBox(height: AppDimens.gapS),
                AppText(
                  text: word.meaning,
                  style: texts.body,
                  maxLines: null,
                  color: colors.textPrimary,
                ),
                const SizedBox(height: AppDimens.gapXs),
                if (word.etymology.isNotEmpty)
                  // One line only (US 12.1); the word card in Hablar shows the whole chain.
                  AppText(
                    text: word.etymology.first,
                    style: texts.caption,
                    color: colors.textSecondary,
                  ),
                const SizedBox(height: AppDimens.gapL),
                AppTextButton(
                  text: isInDictionary ? t.leer.annotation.inDictionary : t.leer.annotation.add,
                  onPressed: onAddPressed,
                  isEnabled: !isInDictionary && !isAdding,
                ),
              ],
              if (error != null)
                AppText(
                  text: LeerExceptionMapper.map(error, t),
                  style: texts.captionSmall,
                  maxLines: null,
                  color: colors.textSecondary,
                ),
              AppTextButton(
                text: t.leer.annotation.close,
                onPressed: onClosePressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
