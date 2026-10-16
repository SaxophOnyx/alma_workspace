import 'package:flutter/material.dart';

import '../../assets/app_asset_utils.dart';

final class AppFonts {
  const AppFonts._();

  static const String serifFamily = 'CormorantGaramond';
  static const String sansFamily = 'Montserrat';

  static const double _serifHeight = 1.4;
  static const double _poetryHeight = 1.6;
  static const double _sansHeight = 1.5;
  static const double _displayHeight = 1.15;
  static const double _smallCapsLetterSpacing = 1.6;

  // Cormorant defaults to old-style figures, which read as letters in counters like "(1)".
  static const List<FontFeature> _serifFeatures = <FontFeature>[FontFeature.liningFigures()];
  static const List<FontFeature> _smallCapsFeatures = <FontFeature>[
    FontFeature.liningFigures(),
    FontFeature.enable('smcp'),
  ];

  static const TextStyle serif_44 = TextStyle(
    fontFamily: serifFamily,
    package: AppAssetUtils.appAssetPackageName,
    fontWeight: FontWeight.w400,
    fontSize: 44,
    height: _displayHeight,
    fontFeatures: _serifFeatures,
  );

  static const TextStyle serif_42 = TextStyle(
    fontFamily: serifFamily,
    package: AppAssetUtils.appAssetPackageName,
    fontWeight: FontWeight.w600,
    fontSize: 42,
    height: _serifHeight,
    fontFeatures: _serifFeatures,
  );

  static const TextStyle serif_32 = TextStyle(
    fontFamily: serifFamily,
    package: AppAssetUtils.appAssetPackageName,
    fontWeight: FontWeight.w500,
    fontSize: 32,
    height: _serifHeight,
    fontFeatures: _serifFeatures,
  );

  static const TextStyle serif_30 = TextStyle(
    fontFamily: serifFamily,
    package: AppAssetUtils.appAssetPackageName,
    fontWeight: FontWeight.w400,
    fontSize: 30,
    height: _serifHeight,
    fontFeatures: _serifFeatures,
  );

  static const TextStyle serif_28 = TextStyle(
    fontFamily: serifFamily,
    package: AppAssetUtils.appAssetPackageName,
    fontWeight: FontWeight.w400,
    fontSize: 28,
    height: _serifHeight,
    fontFeatures: _serifFeatures,
  );

  static const TextStyle serif_26 = TextStyle(
    fontFamily: serifFamily,
    package: AppAssetUtils.appAssetPackageName,
    fontWeight: FontWeight.w500,
    fontSize: 26,
    height: _serifHeight,
    fontFeatures: _serifFeatures,
  );

  static const TextStyle serif_24 = TextStyle(
    fontFamily: serifFamily,
    package: AppAssetUtils.appAssetPackageName,
    fontWeight: FontWeight.w400,
    fontSize: 24,
    height: _poetryHeight,
    fontFeatures: _serifFeatures,
  );

  static const TextStyle serif_22 = TextStyle(
    fontFamily: serifFamily,
    package: AppAssetUtils.appAssetPackageName,
    fontWeight: FontWeight.w400,
    fontSize: 22,
    height: _serifHeight,
    fontFeatures: _serifFeatures,
  );

  static const TextStyle serif_20 = TextStyle(
    fontFamily: serifFamily,
    package: AppAssetUtils.appAssetPackageName,
    fontWeight: FontWeight.w400,
    fontSize: 20,
    height: _serifHeight,
    fontFeatures: _serifFeatures,
  );

  static const TextStyle serifItalic_18 = TextStyle(
    fontFamily: serifFamily,
    package: AppAssetUtils.appAssetPackageName,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    fontSize: 18,
    height: _poetryHeight,
    fontFeatures: _serifFeatures,
  );

  static const TextStyle serifItalic_22 = TextStyle(
    fontFamily: serifFamily,
    package: AppAssetUtils.appAssetPackageName,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    fontSize: 22,
    height: _serifHeight,
    fontFeatures: _serifFeatures,
  );

  static const TextStyle serifSmallCaps_17 = TextStyle(
    fontFamily: serifFamily,
    package: AppAssetUtils.appAssetPackageName,
    fontWeight: FontWeight.w500,
    fontSize: 17,
    height: _serifHeight,
    letterSpacing: _smallCapsLetterSpacing,
    fontFeatures: _smallCapsFeatures,
  );

  static const TextStyle sans_18 = TextStyle(
    fontFamily: sansFamily,
    package: AppAssetUtils.appAssetPackageName,
    fontWeight: FontWeight.w400,
    fontSize: 18,
    height: _sansHeight,
  );

  static const TextStyle sans_16 = TextStyle(
    fontFamily: sansFamily,
    package: AppAssetUtils.appAssetPackageName,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: _sansHeight,
  );

  static const TextStyle sans_15 = TextStyle(
    fontFamily: sansFamily,
    package: AppAssetUtils.appAssetPackageName,
    fontWeight: FontWeight.w400,
    fontSize: 15,
    height: _sansHeight,
  );

  static const TextStyle sans_14 = TextStyle(
    fontFamily: sansFamily,
    package: AppAssetUtils.appAssetPackageName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: _sansHeight,
  );

  static const TextStyle sans_13 = TextStyle(
    fontFamily: sansFamily,
    package: AppAssetUtils.appAssetPackageName,
    fontWeight: FontWeight.w400,
    fontSize: 13,
    height: _sansHeight,
  );
}
