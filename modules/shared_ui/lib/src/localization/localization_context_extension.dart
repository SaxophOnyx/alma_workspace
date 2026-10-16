import 'package:flutter/material.dart';

import 'app_translations.dart';
import 'generated/translations.g.dart' as slang;

extension LocalizationContextExtension on BuildContext {
  AppTranslations get translations => slang.Translations.of(this);
}
