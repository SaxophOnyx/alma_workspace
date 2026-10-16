import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

class SessionEndQuote extends StatelessWidget {
  final Quote quote;
  final VoidCallback onPressed;

  const SessionEndQuote({
    super.key,
    required this.quote,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final AppTextTheme texts = context.appTexts;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppDimens.gapM,
        children: <Widget>[
          AppText(
            text: quote.line,
            style: texts.listTitle,
            maxLines: null,
            textAlign: TextAlign.center,
            color: context.appColors.textPrimary,
          ),
          AppText(
            text: context.translations.respirar.end.source(title: quote.title, year: quote.year),
            style: texts.captionSmall,
            textAlign: TextAlign.center,
            color: context.appColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
