import 'package:flutter/material.dart';

import '../../shared_ui.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isEnabled;

  const AppBackButton({
    super.key,
    required this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextButton(
      text: context.translations.common.backArrow,
      semanticLabel: context.translations.common.back,
      onPressed: onPressed,
      style: AppTextButtonStyle.back,
      isEnabled: isEnabled,
    );
  }
}
