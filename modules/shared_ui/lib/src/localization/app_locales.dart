import 'package:flutter/material.dart';

import 'generated/translations.g.dart' as slang;

final class AppLocales {
  const AppLocales._();

  static List<Locale> get supported => slang.AppLocaleUtils.supportedLocales;

  static Locale get current => slang.LocaleSettings.currentLocale.flutterLocale;
}
