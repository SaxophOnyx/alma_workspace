import 'package:flutter/material.dart';
import 'package:shared_ui/shared_ui.dart';

/// One line per etymology step; every step after the first is led by an arrow.
class EtymologyChain extends StatelessWidget {
  final List<String> steps;

  const EtymologyChain({
    super.key,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    final AppTranslations t = context.translations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < steps.length; i++)
          AppText(
            text: i == 0 ? steps[i] : t.hablar.card.etymologyStep(step: steps[i]),
            style: context.appTexts.caption,
            maxLines: null,
            color: context.appColors.textSecondary,
          ),
      ],
    );
  }
}
