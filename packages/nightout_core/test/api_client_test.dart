import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nightout_core/nightout_core.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.respond);

  final ResponseBody Function(RequestOptions options) respond;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int status, Object? body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

Map<String, Object?> _ok(Object? data) => {
  'status': 'ok',
  'status_code': 200,
  'data': data,
  'code': null,
  'err_msg': null,
};

Map<String, Object?> _no(int statusCode, String? code, String? errMsg) => {
  'status': 'no',
  'status_code': statusCode,
  'data': null,
  'code': code,
  'err_msg': errMsg,
};

const _baseUrl = 'https://api.test/api';

({ApiClient client, _FakeAdapter adapter}) _client(
  ResponseBody Function(RequestOptions options) respond, {
  String baseUrl = _baseUrl,
  String? token = 'tok',
  String? unauthorizedCode,
  Dio? dio,
}) {
  final adapter = _FakeAdapter(respond);
  final client = ApiClient(
    baseUrl: baseUrl,
    unauthorizedCode: unauthorizedCode,
    accessToken: () async => token,
    dio: (dio ?? Dio())..httpClientAdapter = adapter,
  );
  return (client: client, adapter: adapter);
}

Matcher _apiException(int statusCode, String code, String? errMsg) => isA<ApiException>()
    .having((e) => e.statusCode, 'statusCode', statusCode)
    .having((e) => e.code, 'code', code)
    .having((e) => e.errMsg, 'errMsg', errMsg);

Object? _identity(Object? data) => data;

void main() {
  test('ok envelope returns data decoded as MyProfile', () async {
    final (:client, :adapter) = _client(
      (_) => _json(
        200,
        _ok({
          'id': 'u1',
          'display_name': 'วิน',
          'role': 'ADMIN',
          'role_label': 'ผู้ดูแล',
          'can_enter_backoffice': true,
          'phone_e164': '+66812345678',
          'banned_at': '2026-10-01T10:00:00.000Z',
          'ban_reason': 'ยกเลิกบ่อย',
          'avatar_url': null,
        }),
      ),
    );

    final profile = await client.get(
      '/me/profile',
      (data) => MyProfile.fromJson(data! as Map<String, dynamic>),
    );

    expect(adapter.requests.single.uri.toString(), '$_baseUrl/me/profile');
    expect(profile.id, 'u1');
    expect(profile.displayName, 'วิน');
    expect(profile.role, 'ADMIN');
    expect(profile.roleLabel, 'ผู้ดูแล');
    expect(profile.canEnterBackoffice, isTrue);
    expect(profile.phoneE164, '+66812345678');
    expect(profile.bannedAt, DateTime.utc(2026, 10, 1, 10));
    expect(profile.banReason, 'ยกเลิกบ่อย');
    expect(profile.avatarUrl, isNull);
  });

  test('no envelope on HTTP 200 throws with the envelope status_code, code and err_msg', () {
    final (:client, adapter: _) = _client(
      (_) => _json(200, _no(409, 'BOOKING_FULL', 'โต๊ะเต็มแล้ว')),
    );

    expect(
      client.post('/bookings', _identity, body: {'bar_id': 'b1'}),
      throwsA(_apiException(409, 'BOOKING_FULL', 'โต๊ะเต็มแล้ว')),
    );
  });

  test('no envelope without a code falls back to HTTP <status_code>', () {
    final (:client, adapter: _) = _client((_) => _json(200, _no(422, null, null)));

    expect(client.get('/x', _identity), throwsA(_apiException(422, 'HTTP 422', null)));
  });

  test('no envelope on HTTP 404 throws with its code and err_msg', () {
    final (:client, adapter: _) = _client(
      (_) => _json(404, _no(404, 'BAR_NOT_FOUND', 'ไม่พบร้าน')),
    );

    expect(
      client.get('/bars/x', _identity),
      throwsA(_apiException(404, 'BAR_NOT_FOUND', 'ไม่พบร้าน')),
    );
  });

  test('401 with unauthorizedCode throws that code and no err_msg', () {
    final (:client, adapter: _) = _client(
      (_) => _json(401, _no(401, 'UNAUTHORIZED', 'กรุณาเข้าสู่ระบบ')),
      unauthorizedCode: 'MFA_REQUIRED',
    );

    expect(
      client.get('/admin/dashboard', _identity),
      throwsA(_apiException(401, 'MFA_REQUIRED', null)),
    );
  });

  test('401 without unauthorizedCode keeps the envelope code and err_msg', () {
    final (:client, adapter: _) = _client(
      (_) => _json(401, _no(401, 'UNAUTHORIZED', 'กรุณาเข้าสู่ระบบ')),
    );

    expect(
      client.get('/me/profile', _identity),
      throwsA(_apiException(401, 'UNAUTHORIZED', 'กรุณาเข้าสู่ระบบ')),
    );
  });

  test('Nest error body without an envelope uses its message as the code', () {
    final (:client, adapter: _) = _client(
      (_) => _json(400, {
        'statusCode': 400,
        'message': ['email must be an email', 'password too short'],
        'error': 'Bad Request',
      }),
    );

    expect(
      client.post('/x', _identity),
      throwsA(_apiException(400, 'email must be an email, password too short', null)),
    );
  });

  test('error without a JSON body falls back to HTTP <status>', () {
    final (:client, adapter: _) = _client((_) => ResponseBody.fromString('Bad Gateway', 502));

    expect(client.get('/x', _identity), throwsA(_apiException(502, 'HTTP 502', null)));
  });

  test('no response throws ApiException with statusCode 0 naming the trimmed base URL', () {
    final (:client, adapter: _) = _client(
      (options) => throw DioException.connectionError(
        requestOptions: options,
        reason: 'refused',
      ),
      baseUrl: '$_baseUrl/',
    );

    expect(
      client.get('/x', _identity),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 0)
            .having((e) => e.message, 'message', 'ติดต่อเซิร์ฟเวอร์ไม่ได้ ($_baseUrl)'),
      ),
    );
  });

  test('adds Bearer from the access token', () async {
    final (:client, :adapter) = _client((_) => _json(200, _ok(null)));

    await client.get('/x', _identity);

    expect(adapter.requests.single.headers['Authorization'], 'Bearer tok');
  });

  test('keeps an Authorization header the request already has', () async {
    final (:client, :adapter) = _client(
      (_) => _json(200, _ok(null)),
      dio: Dio(BaseOptions(headers: {'authorization': 'Bearer other'})),
    );

    await client.get('/x', _identity);

    expect(adapter.requests.single.headers['Authorization'], 'Bearer other');
  });

  test('sends no Authorization without a token', () async {
    final (:client, :adapter) = _client((_) => _json(200, _ok(null)), token: null);

    await client.get('/x', _identity);

    expect(adapter.requests.single.headers.containsKey('Authorization'), isFalse);
  });

  test('sends method, query and body', () async {
    final (:client, :adapter) = _client((_) => _json(200, _ok(null)));

    await client.get('/bars', _identity, query: {'q': 'rooftop'});
    await client.patch('/me/profile', _identity, body: {'display_name': 'วิน'});

    expect(adapter.requests[0].method, 'GET');
    expect(adapter.requests[0].uri.queryParameters, {'q': 'rooftop'});
    expect(adapter.requests[1].method, 'PATCH');
    expect(adapter.requests[1].data, {'display_name': 'วิน'});
  });

  test('a JSON body that is not an envelope is passed to decode as-is', () async {
    final (:client, adapter: _) = _client((_) => _json(200, {'status': 'up'}));

    expect(await client.get('/health', _identity), {'status': 'up'});
  });
}
