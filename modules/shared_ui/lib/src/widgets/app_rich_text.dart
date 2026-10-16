import 'package:flutter/material.dart';

class AppRichText extends StatelessWidget {
  final TextSpan text;
  final int? maxLines;
  final TextAlign textAlign;

  const AppRichText({
    super.key,
    required this.text,
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
