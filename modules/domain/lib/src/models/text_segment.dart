class TextSegment {
  final String text;
  final String? wordId;

  const TextSegment({
    required this.text,
    this.wordId,
  });

  bool get isLunfardo => wordId != null;
}
