import 'package:flutter/material.dart';

import '../raw/app_fonts.dart';

final class AppTextTheme extends ThemeExtension<AppTextTheme> {
  final TextStyle brand;
  final TextStyle wordHeadline;
  final TextStyle headlineLarge;
  final TextStyle navigation;
  final TextStyle title;
  final TextStyle poetry;
  final TextStyle menu;
  final TextStyle listTitle;
  final TextStyle quote;
  final TextStyle bodyLarge;
  final TextStyle body;
  final TextStyle bodyMedium;
  final TextStyle caption;
  final TextStyle captionSmall;

  const AppTextTheme({
    required this.brand,
    required this.wordHeadline,
    required this.headlineLarge,
    required this.navigation,
    required this.title,
    required this.poetry,
    required this.menu,
    required this.listTitle,
    required this.quote,
    required this.bodyLarge,
    required this.body,
    required this.bodyMedium,
    required this.caption,
    required this.captionSmall,
  });

  factory AppTextTheme.dark() {
    return const AppTextTheme(
      brand: AppFonts.serif_42,
      wordHeadline: AppFonts.serif_32,
      headlineLarge: AppFonts.serif_30,
      navigation: AppFonts.serif_28,
      title: AppFonts.serif_26,
      poetry: AppFonts.serif_24,
      menu: AppFonts.serif_22,
      listTitle: AppFonts.serif_20,
      quote: AppFonts.serifItalic_18,
      bodyLarge: AppFonts.sans_18,
      body: AppFonts.sans_16,
      bodyMedium: AppFonts.sans_15,
      caption: AppFonts.sans_14,
      captionSmall: AppFonts.sans_13,
    );
  }

  @override
  AppTextTheme copyWith({
    TextStyle? brand,
    TextStyle? wordHeadline,
    TextStyle? headlineLarge,
    TextStyle? navigation,
    TextStyle? title,
    TextStyle? poetry,
    TextStyle? menu,
    TextStyle? listTitle,
    TextStyle? quote,
    TextStyle? bodyLarge,
    TextStyle? body,
    TextStyle? bodyMedium,
    TextStyle? caption,
    TextStyle? captionSmall,
  }) {
    return AppTextTheme(
      brand: brand ?? this.brand,
      wordHeadline: wordHeadline ?? this.wordHeadline,
      headlineLarge: headlineLarge ?? this.headlineLarge,
      navigation: navigation ?? this.navigation,
      title: title ?? this.title,
      poetry: poetry ?? this.poetry,
      menu: menu ?? this.menu,
      listTitle: listTitle ?? this.listTitle,
      quote: quote ?? this.quote,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      body: body ?? this.body,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      caption: caption ?? this.caption,
      captionSmall: captionSmall ?? this.captionSmall,
    );
  }

  @override
  AppTextTheme lerp(
    covariant ThemeExtension<AppTextTheme>? other,
    double t,
  ) {
    if (other is! AppTextTheme) {
      return this;
    }

    return AppTextTheme(
      brand: TextStyle.lerp(brand, other.brand, t)!,
      wordHeadline: TextStyle.lerp(wordHeadline, other.wordHeadline, t)!,
      headlineLarge: TextStyle.lerp(headlineLarge, other.headlineLarge, t)!,
      navigation: TextStyle.lerp(navigation, other.navigation, t)!,
      title: TextStyle.lerp(title, other.title, t)!,
      poetry: TextStyle.lerp(poetry, other.poetry, t)!,
      menu: TextStyle.lerp(menu, other.menu, t)!,
      listTitle: TextStyle.lerp(listTitle, other.listTitle, t)!,
      quote: TextStyle.lerp(quote, other.quote, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      captionSmall: TextStyle.lerp(captionSmall, other.captionSmall, t)!,
    );
  }
}
