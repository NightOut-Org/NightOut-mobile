
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_exception.dart';

/// The one HTTP client for the NestJS API. Mirrors web `Rest`
/// (`packages/utils/src/rest.ts`): attaches the Supabase bearer token, unwraps
/// the `{status, status_code, data, code, err_msg}` envelope, and turns every
/// failure into an [ApiException].
class ApiClient {
  ApiClient({
    required String baseUrl,
    String? unauthorizedCode,
    required Future<String?> Function() accessToken,
    Dio? dio,
    bool? logRequests,
  }) : _baseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl,
       _unauthorizedCode = unauthorizedCode,
       _accessToken = accessToken,
       _dio = dio ?? Dio(),
       _logRequests = logRequests ?? kDebugMode {
    _dio.options
      ..baseUrl = _baseUrl
      ..connectTimeout = _timeout
      ..receiveTimeout = _timeout;
  }

  static const _timeout = Duration(seconds: 30);

  final String _baseUrl;

  /// Code thrown for every HTTP 401 instead of the API's own (the Backoffice
  /// passes `MFA_REQUIRED`: a 401 there means "verify the code again").
  final String? _unauthorizedCode;
  final Future<String?> Function() _accessToken;
  final Dio _dio;

  /// Debug aid: prints method, path and status for every call. Never headers,
  /// body or token (see `AGENTS.md`); off in release builds.
  final bool _logRequests;

  Future<T> get<T>(
    String path,
    T Function(Object? data) decode, {
    Map<String, Object?>? query,
  }) => _send('GET', path, decode, query: query);

  Future<T> post<T>(String path, T Function(Object? data) decode, {Object? body}) =>
      _send('POST', path, decode, body: body);

  Future<T> put<T>(String path, T Function(Object? data) decode, {Object? body}) =>
      _send('PUT', path, decode, body: body);

  Future<T> patch<T>(String path, T Function(Object? data) decode, {Object? body}) =>
      _send('PATCH', path, decode, body: body);

  Future<T> delete<T>(String path, T Function(Object? data) decode, {Object? body}) =>
      _send('DELETE', path, decode, body: body);

  Future<T> _send<T>(
    String method,
    String path,
    T Function(Object? data) decode, {
    Object? body,
    Map<String, Object?>? query,
  }) async {
    final target = _target(path, query);
    final clock = Stopwatch()..start();
    _log('→ $method $target');
    final token = _dio.options.headers.containsKey('Authorization') ? null : await _accessToken();
    final Response<Object?> response;
    try {
      response = await _dio.request<Object?>(
        path,
        data: body,
        queryParameters: query,
        options: Options(
          method: method,
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );
    } on DioException catch (e) {
      _log('✗ ${e.response?.statusCode ?? 0} $method $target · ${clock.elapsedMilliseconds}ms');
      throw _failure(e);
    }
    _log('← ${response.statusCode} $method $target · ${clock.elapsedMilliseconds}ms');
    final envelope = _Envelope.parse(response.data);
    if (envelope == null) return decode(response.data);
    if (!envelope.ok) {
      _log('  code=${envelope.code ?? 'HTTP ${envelope.statusCode}'}');
      throw ApiException(
        envelope.statusCode,
        envelope.code ?? 'HTTP ${envelope.statusCode}',
        envelope.errMsg,
      );
    }
    return decode(envelope.data);
  }

  /// Path with query, e.g. `/admin/views/bars?page=1` — enough to find the call.
  static String _target(String path, Map<String, Object?>? query) {
    if (query == null || query.isEmpty) return path;
    final separator = path.contains('?') ? '&' : '?';
    return '$path$separator${Uri(queryParameters: query).query}';
  }

  void _log(String line) {
    if (!_logRequests) return;
    debugPrint("API: $line");
  }

  ApiException _failure(DioException e) {
    final response = e.response;
    if (response == null) return ApiException(0, 'ติดต่อเซิร์ฟเวอร์ไม่ได้ ($_baseUrl)', null);

    final status = response.statusCode ?? 0;
    final envelope = _Envelope.parse(response.data);
    final unauthorized = status == 401 ? _unauthorizedCode : null;
    final code =
        unauthorized ??
        (envelope != null ? envelope.code : _nestMessage(response.data)) ??
        'HTTP $status';
    return ApiException(status, code, unauthorized != null ? null : envelope?.errMsg);
  }

  /// NestJS's own error body (`{statusCode, message, error}`), from guards and
  /// pipes that run before the envelope is built.
  static String? _nestMessage(Object? body) => switch (body) {
    {'message': final String message} => message,
    {'message': final List<Object?> messages} => messages.join(', '),
    _ => null,
  };
}

class _Envelope {
  const _Envelope({
    required this.ok,
    required this.statusCode,
    required this.data,
    required this.code,
    required this.errMsg,
  });

  final bool ok;
  final int statusCode;
  final Object? data;
  final String? code;
  final String? errMsg;

  /// Same test as web `isEnvelope`; anything else is a plain body.
  static _Envelope? parse(Object? body) {
    if (body is! Map || !body.containsKey('status_code')) return null;
    final status = body['status'];
    if (status != 'ok' && status != 'no') return null;
    return _Envelope(
      ok: status == 'ok',
      statusCode: (body['status_code'] as num).toInt(),
      data: body['data'],
      code: body['code'] as String?,
      errMsg: body['err_msg'] as String?,
    );
  }
}
