import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class ContextCard extends StatelessWidget {
  final TangoText text;
  final VoidCallback onReadPressed;

  const ContextCard({
    super.key,
    required this.text,
    required this.onReadPressed,
  });

  @override
  Widget build(BuildContext context) {
    final AppTextTheme texts = context.appTexts;
    final AppColorsTheme colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppFadeIn(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppDimens.gapS,
            children: <Widget>[
              AppSectionTitle(text: text.title),
              AppText(
                text: text.author,
                style: texts.listTitle,
                maxLines: null,
                color: colors.textSecondary,
              ),
              AppText(
                text: '${text.year}',
                style: texts.captionSmall,
                color: colors.textSecondary,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.gapXl),
        AppFadeIn(
          delay: AppMotions.staggerStep * 2,
          child: AppText(
            text: text.context,
            style: texts.bodyLarge,
            maxLines: null,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimens.gapXl),
        AppFadeIn(
          delay: AppMotions.staggerInterval,
          child: AppTextButton(
            text: context.translations.leer.read,
            onPressed: onReadPressed,
            style: AppTextButtonStyle.title,
          ),
        ),
      ],
    );
  }
}
