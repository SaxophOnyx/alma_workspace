import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../shared_ui.dart';

class AppImage extends StatelessWidget {
  final String source;
  final bool _isNetwork;
  final BoxFit fit;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const AppImage._(
    this.source,
    this._isNetwork, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.onTap,
  });

  const AppImage.asset(
    String source, {
    Key? key,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    VoidCallback? onTap,
  }) : this._(source, false, key: key, fit: fit, width: width, height: height, onTap: onTap);

  const AppImage.network(
    String source, {
    Key? key,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    VoidCallback? onTap,
  }) : this._(source, true, key: key, fit: fit, width: width, height: height, onTap: onTap);

  @override
  Widget build(BuildContext context) {
    final Widget image = _isNetwork
        ? _AppNetworkImage(url: source, key: key, fit: fit, width: width, height: height)
        : _AppAssetImage(
            source,
            key: key,
            fit: fit,
            width: width,
            height: height,
            package: AppAssetUtils.appAssetPackageName,
          );

    if (onTap == null) return image;
    return InkWell(onTap: onTap, child: image);
  }
}

class _AppAssetImage extends StatelessWidget {
  final String source;
  final BoxFit fit;
  final double? width;
  final double? height;
  final String? package;

  const _AppAssetImage(
    this.source, {
    super.key,
    required this.fit,
    this.width,
    this.height,
    this.package,
  });

  @override
  Widget build(BuildContext context) {
    return AppAssetUtils.isSvgAsset(source)
        ? SvgPicture.asset(
            source,
            package: package,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (_, _, _) => const Center(child: Icon(Icons.broken_image)),
          )
        : Image.asset(
            source,
            package: package,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (_, _, _) => const Center(child: Icon(Icons.broken_image)),
          );
  }
}

class _AppNetworkImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;

  const _AppNetworkImage({
    super.key,
    required this.url,
    required this.fit,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (AppAssetUtils.isSvgAsset(url)) {
      return SvgPicture.network(
        url,
        fit: fit,
        width: width,
        height: height,
        placeholderBuilder: (_) => const Center(child: CircularProgressIndicator()),
        errorBuilder: (_, _, _) => const Center(child: Icon(Icons.broken_image)),
      );
    }

    final double pixelRatio = MediaQuery.devicePixelRatioOf(context);
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: width != null ? (width! * pixelRatio).round().clamp(0, 2048) : null,
      memCacheHeight: height != null ? (height! * pixelRatio).round().clamp(0, 2048) : null,
      progressIndicatorBuilder: (_, _, DownloadProgress p) => Center(
        child: CircularProgressIndicator(
          value: p.totalSize == null ? null : p.downloaded / p.totalSize!,
        ),
      ),
      errorWidget: (_, _, _) => const Center(child: Icon(Icons.broken_image)),
    );
  }
}
