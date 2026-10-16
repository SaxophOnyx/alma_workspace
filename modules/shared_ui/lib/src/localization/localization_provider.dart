import 'package:flutter/material.dart';

import 'generated/translations.g.dart' as slang;

class LocalizationProvider extends StatelessWidget {
  final Widget child;

  const LocalizationProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return slang.TranslationProvider(child: child);
  }
}
