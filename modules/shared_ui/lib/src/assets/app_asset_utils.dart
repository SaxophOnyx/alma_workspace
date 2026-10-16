final class AppAssetUtils {
  const AppAssetUtils._();

  static const String appAssetPackageName = 'shared_ui';

  static bool isSvgAsset(String source) {
    final Uri? uri = Uri.tryParse(source);
    final String path = uri?.path ?? source;
    return path.toLowerCase().endsWith('.svg');
  }
}
