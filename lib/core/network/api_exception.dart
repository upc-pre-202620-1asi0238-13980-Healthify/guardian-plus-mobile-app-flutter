/// A request that did not succeed, with a message the user understands.
///
/// [statusCode] is null when the server could not be reached at all.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const new(this.message, {this.statusCode});

  @override
  String toString() => message;
}
