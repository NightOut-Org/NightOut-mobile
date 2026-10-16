import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nightoutadmin/models/auth/auth.models.dart';
import 'package:nightoutadmin/modules/controller/auth.ctrl.dart';
import 'package:nightoutadmin/modules/services/auth.service.dart';
import 'package:nightoutadmin/utils/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('factor ที่ verified ใน /auth/v1/user ไม่ถูก enroll ซ้ำ', () async {
    final harness = _Harness();
    harness.user = _user(factors: [_factor(status: 'verified')]);

    await harness.signIn();

    expect(harness.authCalls.where((call) => call.method == 'POST' && call.path == '/auth/v1/factors'), isEmpty);
    expect(
      harness.authCalls.map((call) => '${call.method} ${call.path}'),
      containsAllInOrder(<String>['POST /auth/v1/token', 'GET /auth/v1/user']),
    );
    expect(harness.state.phase, LoginPhase.verify);
    expect(harness.state.factorId, 'factor-1');
    expect(harness.state.session, isNull);
    expect(harness.authCalls.where((call) => call.path == '/auth/v1/logout'), isEmpty);
  });

  test('factor ที่ยังไม่ verified ถูกล้างก่อน enroll ด้วยค่าจาก /auth/v1/user', () async {
    final harness = _Harness();
    harness.user = _user(
      factors: [
        _factor(
          id: 'stale-factor',
          status: 'unverified',
          factorType: 'totp',
          friendlyName: 'NightOut Admin',
          issuer: 'NightOut Admin',
        ),
      ],
    );

    await harness.signIn();

    final deleteAt = harness.authCalls.indexWhere(
      (call) => call.method == 'DELETE' && call.path == '/auth/v1/factors/stale-factor',
    );
    final enrollAt = harness.authCalls.indexWhere(
      (call) => call.method == 'POST' && call.path == '/auth/v1/factors',
    );
    expect(deleteAt, greaterThanOrEqualTo(0));
    expect(enrollAt, greaterThan(deleteAt));
    expect(harness.authCalls[enrollAt].body, {
      'factor_type': 'totp',
      'friendly_name': 'NightOut Admin',
      'issuer': 'NightOut Admin',
    });
    expect(harness.state.phase, LoginPhase.enroll);
    expect(harness.state.enrollment?.secret, 'SECRET');
    expect(harness.authCalls.where((call) => call.path == '/auth/v1/logout'), isEmpty);
  });

  test('enroll ได้ 422 แล้วไม่ signOut', () async {
    final harness = _Harness();
    harness.user = _user(factors: const []);
    harness.enrollStatus = 422;

    await harness.signIn();

    expect(harness.authCalls.where((call) => call.path == '/auth/v1/logout'), isEmpty);
    expect(harness.state.session, isNull);
    expect(harness.state.phase, LoginPhase.credentials);
    expect(harness.state.notice, 'A factor with the same friendly name already exists');
  });

  test('รหัสไม่ถูกต้องแล้วไม่ signOut', () async {
    final harness = _Harness();
    harness.user = _user(factors: [_factor(status: 'verified')]);
    await harness.signIn();

    harness.verifyStatus = 400;
    await harness.container.read(authCtrl.notifier).submitCode('123456');

    expect(harness.authCalls.where((call) => call.path == '/auth/v1/logout'), isEmpty);
    expect(harness.state.phase, LoginPhase.verify);
    expect(harness.state.codeInvalid, isTrue);
    expect(
      harness.authCalls.map((call) => call.path),
      containsAllInOrder(<String>[
        '/auth/v1/factors/factor-1/challenge',
        '/auth/v1/factors/factor-1/verify',
      ]),
    );
  });

  test('บัญชีที่เข้า Backoffice ไม่ได้ถูก signOut พร้อมข้อความชั้น', () async {
    final harness = _Harness()..canEnter = false;

    await harness.signIn();

    expect(harness.authCalls.where((call) => call.method == 'POST' && call.path == '/auth/v1/logout'), isNotEmpty);
    expect(harness.state.notice, 'บัญชีนี้เป็นชั้น ผู้ดูแล เข้า Backoffice ไม่ได้');
    expect(harness.state.session, isNull);
  });

  test('อ่าน factor_type friendly_name issuer จาก factors ของ /auth/v1/user', () {
    final user = AuthUser.fromJson(
      jsonDecode(_user(factors: [_factor(status: 'verified')])) as Map<String, dynamic>,
    );

    final factor = user.verifiedTotp;
    expect(factor, isNotNull);
    expect(factor!.factorType, 'totp');
    expect(factor.friendlyName, 'NightOut Admin');
    expect(factor.issuer, 'NightOut Admin');
    expect(user.mfaPlan.shouldEnroll, isFalse);
  });
}

class _HttpCall {
  const _HttpCall(this.method, this.path, this.body);

  final String method;
  final String path;
  final Map<String, dynamic>? body;
}

class _ScriptHttp extends Http {
  _ScriptHttp({required this.calls, required this.handle}) : super(baseUrl: 'https://example.test');

  final List<_HttpCall> calls;
  final Future<HttpResult> Function(_HttpCall call) handle;

  @override
  Future<HttpResult> send({
    required String method,
    required String path,
    Map<String, String>? query,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) {
    final call = _HttpCall(method, path, body);
    calls.add(call);
    return handle(call);
  }
}

class _Harness {
  _Harness() {
    final authHttp = _ScriptHttp(calls: authCalls, handle: _onAuth);
    final apiHttp = _ScriptHttp(calls: apiCalls, handle: _onApi);
    container = ProviderContainer(
      overrides: [
        authService.overrideWithValue(
          AuthService(
            http: apiHttp,
            authHttp: authHttp,
            baseUrl: 'https://api.test',
            supabaseUrl: 'https://auth.test',
            anonKey: 'anon',
          ),
        ),
      ],
    );
  }

  final authCalls = <_HttpCall>[];
  final apiCalls = <_HttpCall>[];
  late final ProviderContainer container;
  String user = _user(factors: const []);
  bool canEnter = true;
  int enrollStatus = 200;
  int verifyStatus = 200;

  AuthState get state => container.read(authCtrl);

  Future<void> signIn() {
    return container.read(authCtrl.notifier).submitPassword(email: 'admin@nightout.co', password: 'secret');
  }

  Future<HttpResult> _onAuth(_HttpCall call) async {
    if (call.path == '/auth/v1/token') {
      return _json(200, {
        'access_token': 'access-token',
        'refresh_token': 'refresh-token',
        'expires_in': 3600,
        'token_type': 'bearer',
        'user': {'id': 'user-1', 'email': 'admin@nightout.co'},
      });
    }
    if (call.path == '/auth/v1/user') {
      return HttpResult(statusCode: 200, body: user);
    }
    if (call.method == 'DELETE' && call.path.startsWith('/auth/v1/factors/')) {
      return _json(200, {
        'id': 'stale-factor',
        'factor_type': 'totp',
        'friendly_name': 'NightOut Admin',
        'issuer': 'NightOut Admin',
        'status': 'unverified',
      });
    }
    if (call.method == 'POST' && call.path == '/auth/v1/factors') {
      if (enrollStatus >= 400) {
        return _json(enrollStatus, {
          'error_code': 'mfa_factor_name_conflict',
          'msg': 'A factor with the same friendly name already exists',
        });
      }
      return _json(200, {
        'id': 'new-factor',
        'totp': {
          'secret': 'SECRET',
          'uri': 'otpauth://totp/NightOut%20Admin:admin@nightout.co?secret=SECRET&issuer=NightOut%20Admin',
          'qr_code': 'data:image/svg+xml;utf-8,<svg></svg>',
        },
      });
    }
    if (call.path.endsWith('/challenge')) {
      return _json(200, {'id': 'challenge-1'});
    }
    if (call.path.endsWith('/verify')) {
      if (verifyStatus >= 400) {
        return _json(verifyStatus, {
          'error_code': 'mfa_verification_failed',
          'msg': 'Invalid TOTP code entered',
        });
      }
      return _json(200, {
        'access_token': 'aal2-token',
        'refresh_token': 'aal2-refresh',
        'expires_in': 3600,
        'token_type': 'bearer',
        'user': {'id': 'user-1', 'email': 'admin@nightout.co'},
      });
    }
    if (call.path == '/auth/v1/logout') {
      return _json(204, {});
    }
    return _json(500, {'msg': 'unexpected ${call.method} ${call.path}'});
  }

  Future<HttpResult> _onApi(_HttpCall call) async {
    if (call.path == '/me/profile') {
      return _json(200, {
        'data': {
          'id': 'user-1',
          'display_name': 'Admin',
          'role': 'admin',
          'role_label': 'ผู้ดูแล',
          'can_enter_backoffice': canEnter,
        },
      });
    }
    if (call.path == '/api/admin/dashboard') {
      return _json(200, {
        'data': {'total': 0, 'unit': 'รายการ', 'items': []},
      });
    }
    return _json(500, {'msg': 'unexpected ${call.method} ${call.path}'});
  }
}

HttpResult _json(int status, Map<String, dynamic> body) {
  return HttpResult(statusCode: status, body: jsonEncode(body));
}

String _user({required List<Map<String, dynamic>> factors}) {
  return jsonEncode({
    'id': 'user-1',
    'email': 'admin@nightout.co',
    'factors': factors,
  });
}

Map<String, dynamic> _factor({
  String id = 'factor-1',
  String status = 'verified',
  String factorType = 'totp',
  String friendlyName = 'NightOut Admin',
  String issuer = 'NightOut Admin',
}) {
  return {
    'id': id,
    'status': status,
    'factor_type': factorType,
    'friendly_name': friendlyName,
    'issuer': issuer,
  };
}
