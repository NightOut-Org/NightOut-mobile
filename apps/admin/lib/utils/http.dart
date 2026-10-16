import 'package:dio/dio.dart';
import 'package:nightout_core/nightout_core.dart';

class HttpResult {
  const HttpResult({required this.statusCode, required this.body});

  final int statusCode;
  final String body;
}

class Http {
  Http({Dio? dio, String? baseUrl})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: _trim(baseUrl ?? Env.apiBaseUrl),
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20),
              responseType: ResponseType.plain,
            ),
          );

  final Dio _dio;

  static String _trim(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  Future<HttpResult> send({
    required String method,
    required String path,
    Map<String, String>? query,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final response = await _dio.request<String>(
      path,
      data: body,
      queryParameters: query,
      options: Options(
        method: method,
        headers: headers,
        responseType: ResponseType.plain,
        contentType: body == null ? null : Headers.jsonContentType,
        validateStatus: (status) => status != null,
      ),
    );
    return HttpResult(statusCode: response.statusCode ?? 0, body: response.data ?? '');
  }
}
