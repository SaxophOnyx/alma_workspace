import 'package:core/core.dart';

import 'local_storage_operation.dart';

class LocalStorageException extends AppException {
  final LocalStorageOperation operation;

  const LocalStorageException(this.operation) : super('local_storage_operation_failed');
}
