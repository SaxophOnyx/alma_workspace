class AppException implements Exception {
  final String message;

  const AppException(this.message);

  const AppException.unknown() : message = 'Unknown exception';

  @override
  String toString() => message;
}
