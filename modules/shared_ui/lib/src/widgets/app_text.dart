import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final int? maxLines;
  final TextAlign? textAlign;
  final Color? color;

  const AppText({
    super.key,
    required this.text,
    required this.style,
    this.maxLines = 1,
    this.textAlign,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle resolvedStyle = style.copyWith(color: color);

    return Text(
      text,
      style: resolvedStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
  }
}
