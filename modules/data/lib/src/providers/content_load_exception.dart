import 'package:core/core.dart';

import 'content_type.dart';

class ContentLoadException extends AppException {
  final ContentType type;

  const ContentLoadException(this.type) : super('content_load_failed');
}
