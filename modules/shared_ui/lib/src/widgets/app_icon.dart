import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../shared_ui.dart';

class AppIcon extends StatelessWidget {
  final String source;
  final double size;
  final Color? color;

  const AppIcon.asset(
    this.source, {
    super.key,
    this.size = AppDimens.iconSize,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (AppAssetUtils.isSvgAsset(source)) {
      return SvgPicture.asset(
        source,
        package: AppAssetUtils.appAssetPackageName,
        width: size,
        height: size,
        colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      );
    }

    return Image.asset(
      source,
      package: AppAssetUtils.appAssetPackageName,
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: color != null ? BlendMode.srcIn : null,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );
  }
}
