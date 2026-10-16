import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class ContextCard extends StatelessWidget {
  final TangoText text;

  const ContextCard({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final AppTextTheme texts = context.appTexts;
    final AppColorsTheme colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppText(
          text: text.title,
          style: texts.title,
          maxLines: null,
          color: colors.textPrimary,
        ),
        const SizedBox(height: AppDimens.gapS),
        AppText(
          text: text.author,
          style: texts.captionSmall,
          maxLines: null,
          color: colors.textSecondary,
        ),
        AppText(
          text: '${text.year}',
          style: texts.captionSmall,
          color: colors.textSecondary,
        ),
        const SizedBox(height: AppDimens.gapXl),
        AppText(
          text: text.context,
          style: texts.body,
          maxLines: null,
          color: colors.textPrimary,
        ),
      ],
    );
  }
}
