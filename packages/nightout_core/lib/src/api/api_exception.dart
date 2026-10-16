/// Mirrors web `ApiError` (`packages/utils/src/rest.ts`). Branch on [code];
/// show [message] to users, since `err_msg` is already Thai.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.code, this.errMsg);

  /// 0 when the server could not be reached.
  final int statusCode;
  final String code;
  final String? errMsg;

  String get message => errMsg ?? code;

  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}
