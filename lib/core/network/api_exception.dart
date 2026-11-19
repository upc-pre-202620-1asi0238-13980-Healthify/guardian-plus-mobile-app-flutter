/// A request that did not succeed, with a message the user understands.
///
/// [statusCode] is null when the server could not be reached at all.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  final String? code;
  final String? details;

  const ApiException(this.message, {this.statusCode, this.code, this.details});

  @override
  String toString() => message;
}
