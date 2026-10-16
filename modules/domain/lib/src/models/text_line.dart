import 'text_segment.dart';

class TextLine {
  final List<TextSegment> segments;

  const TextLine({
    required this.segments,
  });

  String get text => segments.map((TextSegment segment) => segment.text).join();
}
