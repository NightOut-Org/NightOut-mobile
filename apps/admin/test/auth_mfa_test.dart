import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nightout_core/nightout_core.dart';
import 'package:nightoutadmin/modules/controller/auth.ctrl.dart';
import 'package:nightoutadmin/providers/api.provider.dart';
import 'package:nightoutadmin/providers/dashboard.provider.dart';

const _email = 'admin@nightout.co';
const _goodCode = '123456';
const _codeMessage = 'รหัส 6 หลักไม่ถูกต้องหรือหมดเวลาแล้ว ใช้รหัสล่าสุดจากแอปแล้วลองอีกครั้ง';

void main() {
  test('factor ที่ verified แล้วไปขั้นใส่รหัส โดยไม่ enroll ซ้ำ', () async {
    final h = _Harness()..auth.mfa.factors = [_factor('factor-1', FactorStatus.verified)];

    await h.signIn();

    final state = h.state as AdminNeedsCode;
    expect(state.factorId, 'factor-1');
    expect(state.enrollment, isNull);
    expect(state.email, _email);
    expect(h.auth.calls, ['signInWithPassword $_email', 'listFactors']);
  });

  test('factor ที่ยังไม่ verified ถูก unenroll ก่อน enroll ใหม่', () async {
    final h = _Harness()..auth.mfa.factors = [_factor('stale-factor', FactorStatus.unverified)];

    await h.signIn();

    expect(h.auth.calls, [
      'signInWithPassword $_email',
      'listFactors',
      'unenroll stale-factor',
      'enroll totp issuer=NightOut Admin name=NightOut Admin',
    ]);
    final state = h.state as AdminNeedsCode;
    expect(state.factorId, 'new-factor');
    expect(state.enrollment?.secret, 'SECRET');
  });

  test('enroll ล้มเหลวแล้วไม่ signOut และแสดงข้อความบนขั้นรหัสผ่าน', () async {
    const conflict = 'A factor with the friendly name "NightOut Admin" for this user already exists';
    final h = _Harness()
      ..auth.mfa.enrollError = const AuthException(conflict, statusCode: '422', code: 'mfa_factor_name_conflict');

    await h.signIn();

    expect(h.auth.calls, isNot(contains('signOut')));
    expect(h.auth.currentSession, isNotNull);
    expect(h.state, isA<AdminSignedOut>().having((s) => s.error, 'error', conflict));
  });

  test('รหัสผิดบนขั้นยืนยันแล้วไม่ signOut และแสดงข้อความบนขั้นรหัส', () async {
    final h = _Harness()..auth.mfa.factors = [_factor('factor-1', FactorStatus.verified)];
    await h.signIn();

    await h.container.read(authCtrl.notifier).verify('000000');

    expect(h.auth.calls, isNot(contains('signOut')));
    expect(h.auth.calls.last, 'challengeAndVerify factor-1 000000');
    final state = h.state as AdminNeedsCode;
    expect(state.error, _codeMessage);
    expect(state.enrollment, isNull);
  });

  test('รหัสผิดบนขั้นผูกแอปยังเห็นรหัสลับเดิม', () async {
    final h = _Harness();
    await h.signIn();

    await h.container.read(authCtrl.notifier).verify('000000');

    final state = h.state as AdminNeedsCode;
    expect(state.error, _codeMessage);
    expect(state.factorId, 'new-factor');
    expect(state.enrollment?.secret, 'SECRET');
  });

  test('รหัสถูกแล้วเข้าแอปพร้อมโปรไฟล์', () async {
    final h = _Harness()..auth.mfa.factors = [_factor('factor-1', FactorStatus.verified)];
    await h.signIn();

    await h.container.read(authCtrl.notifier).verify(_goodCode);

    final state = h.state as AdminSignedIn;
    expect(state.profile.displayName, 'แอดมิน');
    expect(state.email, _email);
  });

  test('บัญชีที่เข้า Backoffice ไม่ได้ถูก signOut พร้อมข้อความชั้นแบบเว็บ', () async {
    final h = _Harness()..api.profile = _profile(canEnter: false);

    await h.signIn();

    expect(h.auth.calls, ['signInWithPassword $_email', 'signOut']);
    expect(
      h.state,
      isA<AdminSignedOut>().having((s) => s.error, 'error', 'บัญชีนี้เป็นชั้น "ลูกค้า" ซึ่งเข้า Backoffice ไม่ได้'),
    );
  });

  test('อ่าน /me/profile ไม่ได้ถูก signOut พร้อมข้อความว่า API มีปัญหา', () async {
    final h = _Harness()..api.profile = const ApiException(500, 'INTERNAL', 'ระบบขัดข้อง');

    await h.signIn();

    expect(h.auth.calls, ['signInWithPassword $_email', 'signOut']);
    expect(
      h.state,
      isA<AdminSignedOut>().having(
        (s) => s.error,
        'error',
        'ล็อกอินผ่านแล้ว แต่อ่านข้อมูลบัญชีจากเซิร์ฟเวอร์ไม่ได้ (500 · INTERNAL) — ไม่ใช่เรื่องสิทธิ์ ให้ตรวจ API / Supabase',
      ),
    );
  });

  test('รหัสผ่านผิดแสดงข้อความภาษาไทยและไม่เรียก /me/profile', () async {
    final h = _Harness()
      ..auth.signInError = const AuthException(
        'Invalid login credentials',
        statusCode: '400',
        code: 'invalid_credentials',
      );

    await h.signIn();

    expect(h.api.calls, isEmpty);
    expect(h.state, isA<AdminSignedOut>().having((s) => s.error, 'error', 'อีเมลหรือรหัสผ่านไม่ถูกต้อง'));
  });

  test('กดเข้าสู่ระบบซ้ำระหว่างรอ เริ่ม flow เดียว', () async {
    final h = _Harness();
    final notifier = h.container.read(authCtrl.notifier);

    await Future.wait([notifier.signIn(_email, 'pw'), notifier.signIn(_email, 'pw')]);

    expect(h.auth.calls.where((c) => c.startsWith('signInWithPassword')), hasLength(1));
    expect(h.auth.calls.where((c) => c.startsWith('enroll')), hasLength(1));
    expect(h.container.read(authBusy), isFalse);
  });

  test('requireMfa ตอนมี session ไปขั้นใส่รหัส', () async {
    final h = _Harness(session: _session())..auth.mfa.factors = [_factor('factor-1', FactorStatus.verified)];

    await h.container.read(authCtrl.notifier).requireMfa();

    expect(h.state, isA<AdminNeedsCode>().having((s) => s.factorId, 'factorId', 'factor-1'));
    expect(h.auth.calls, isNot(contains('signOut')));
  });

  test('requireMfa ตอนไม่มี session กลับไปขั้นรหัสผ่าน', () async {
    final h = _Harness();

    await h.container.read(authCtrl.notifier).requireMfa();

    expect(h.state, isA<AdminSignedOut>().having((s) => s.error, 'error', isNull));
    expect(h.auth.calls, isEmpty);
  });

  test('restore ด้วย session aal1 ไปขั้นใส่รหัส', () async {
    final h = _Harness(session: _session())..auth.mfa.factors = [_factor('factor-1', FactorStatus.verified)];

    await h.container.read(authCtrl.notifier).restore();

    expect(h.state, isA<AdminNeedsCode>().having((s) => s.email, 'email', _email));
    expect(h.api.calls, ['/me/profile']);
  });

  test('restore ด้วย session aal2 เข้าแอปเลย', () async {
    final h = _Harness(session: _session())..auth.mfa.level = AuthenticatorAssuranceLevels.aal2;

    await h.container.read(authCtrl.notifier).restore();

    expect(h.state, isA<AdminSignedIn>().having((s) => s.email, 'email', _email));
    expect(h.auth.calls, isEmpty);
  });

  test('restore ด้วย session ที่หมดอายุ refresh ก่อนเรียก /me/profile', () async {
    final h = _Harness(session: _session()..expiresAt = 0)..auth.mfa.level = AuthenticatorAssuranceLevels.aal2;
    h.api.onGet = () => h.auth.calls.add('GET /me/profile with ${h.auth.currentSession?.accessToken}');

    await h.container.read(authCtrl.notifier).restore();

    expect(h.auth.calls, ['refreshSession', 'GET /me/profile with refreshed-token']);
    expect(h.state, isA<AdminSignedIn>());
  });

  test('session ถูกยกเลิกจากภายนอกแล้วกลับไปขั้นรหัสผ่าน', () async {
    final h = _Harness(session: _session())..auth.mfa.level = AuthenticatorAssuranceLevels.aal2;
    await h.container.read(authCtrl.notifier).restore();

    h.auth.changes.add(AuthState(AuthChangeEvent.signedOut, null));
    await _settle();

    expect(h.state, isA<AdminSignedOut>());
  });

  test('แดชบอร์ดอ่านตัวเลข 7 ช่องจาก /admin/dashboard', () async {
    final h = _Harness()
      ..api.dashboard = {
        'bookings_today': 1,
        'forfeited_today': 2,
        'bars_pending': 3,
        'deposits_to_verify': 4,
        'payouts_pending': 5,
        'promo_slips_pending': 6,
        'reviews_reported': 7,
      };

    final d = (await h.container.read(dashboardProvider.future))!;

    expect(
      [
        d.bookingsToday,
        d.forfeitedToday,
        d.barsPending,
        d.depositsToVerify,
        d.payoutsPending,
        d.promoSlipsPending,
        d.reviewsReported,
      ],
      [1, 2, 3, 4, 5, 6, 7],
    );
  });

  test('แดชบอร์ดได้ MFA_REQUIRED แล้วไปขั้นใส่รหัส ไม่ signOut', () async {
    final h = _Harness(session: _session())
      ..auth.mfa.level = AuthenticatorAssuranceLevels.aal2
      ..auth.mfa.factors = [_factor('factor-1', FactorStatus.verified)]
      ..api.dashboard = const ApiException(401, mfaRequiredCode, null);
    await h.container.read(authCtrl.notifier).restore();
    final sub = h.container.listen(dashboardProvider, (_, _) {});
    addTearDown(sub.close);

    await expectLater(h.container.read(dashboardProvider.future), throwsA(isA<ApiException>()));
    await _settle();

    expect(h.state, isA<AdminNeedsCode>().having((s) => s.factorId, 'factorId', 'factor-1'));
    expect(h.auth.calls, isNot(contains('signOut')));
  });
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

class _Harness {
  _Harness({Session? session}) : auth = _FakeAuth(session) {
    container = ProviderContainer(
      overrides: [
        supabaseAuthProvider.overrideWithValue(auth),
        apiClientProvider.overrideWithValue(api),
      ],
    );
    addTearDown(container.dispose);
    container.read(authCtrl);
  }

  final _FakeAuth auth;
  final api = _FakeApi();
  late final ProviderContainer container;

  AdminAuth get state => container.read(authCtrl);

  /// Waits one more turn so a late signedOut event from the fake gets a chance to overwrite the state.
  Future<void> signIn() async {
    await container.read(authCtrl.notifier).signIn(_email, 'pw');
    await _settle();
  }
}

class _FakeAuth implements GoTrueClient {
  _FakeAuth(this._session);

  final calls = <String>[];
  final changes = StreamController<AuthState>.broadcast();
  late final _FakeMfa _mfa = _FakeMfa(this);
  Session? _session;
  AuthException? signInError;

  @override
  _FakeMfa get mfa => _mfa;

  @override
  Session? get currentSession => _session;

  @override
  Stream<AuthState> get onAuthStateChange => changes.stream;

  @override
  Future<AuthResponse> signInWithPassword({
    String? email,
    String? phone,
    required String password,
    String? captchaToken,
  }) async {
    calls.add('signInWithPassword $email');
    if (signInError case final error?) throw error;
    _session = _sessionFor(email!);
    return AuthResponse(session: _session);
  }

  @override
  Future<Session?> getSession() async {
    if (_session case final session? when session.isExpired) {
      calls.add('refreshSession');
      _session = Session(accessToken: 'refreshed-token', tokenType: 'bearer', user: session.user);
    }
    return _session;
  }

  @override
  Future<void> signOut({Object? scope}) async {
    calls.add('signOut');
    _session = null;
    // gotrue delivers the event asynchronously; deliver it after signOut returns, the worst case.
    Timer.run(() => changes.add(AuthState(AuthChangeEvent.signedOut, null)));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeMfa implements GoTrueMFAApi {
  _FakeMfa(this._auth);

  final _FakeAuth _auth;
  List<Factor> factors = [];
  AuthException? enrollError;
  AuthenticatorAssuranceLevels level = AuthenticatorAssuranceLevels.aal1;

  @override
  Future<AuthMFAListFactorsResponse> listFactors() async {
    _auth.calls.add('listFactors');
    final verifiedTotp = factors
        .where((f) => f.factorType == FactorType.totp && f.status == FactorStatus.verified)
        .toList();
    return AuthMFAListFactorsResponse(all: factors, totp: verifiedTotp, phone: const []);
  }

  @override
  Future<AuthMFAUnenrollResponse> unenroll(String factorId) async {
    _auth.calls.add('unenroll $factorId');
    factors = factors.where((f) => f.id != factorId).toList();
    return AuthMFAUnenrollResponse(id: factorId);
  }

  @override
  Future<AuthMFAEnrollResponse> enroll({
    FactorType factorType = FactorType.totp,
    String? issuer,
    String? friendlyName,
    String? phone,
  }) async {
    _auth.calls.add('enroll ${factorType.name} issuer=$issuer name=$friendlyName');
    if (enrollError case final error?) throw error;
    return const AuthMFAEnrollResponse(
      id: 'new-factor',
      type: FactorType.totp,
      totp: TOTPEnrollment(qrCode: 'qr', secret: 'SECRET', uri: 'otpauth://totp/NightOut%20Admin'),
    );
  }

  @override
  Future<AuthMFAVerifyResponse> challengeAndVerify({required String factorId, required String code}) async {
    _auth.calls.add('challengeAndVerify $factorId $code');
    if (code != _goodCode) {
      throw const AuthException('Invalid TOTP code entered', statusCode: '422', code: 'mfa_verification_failed');
    }
    level = AuthenticatorAssuranceLevels.aal2;
    return AuthMFAVerifyResponse(
      accessToken: 'aal2-token',
      tokenType: 'bearer',
      expiresIn: const Duration(hours: 1),
      refreshToken: 'refresh',
      user: _user(_email),
    );
  }

  @override
  AuthMFAGetAuthenticatorAssuranceLevelResponse getAuthenticatorAssuranceLevel() =>
      AuthMFAGetAuthenticatorAssuranceLevelResponse(
        currentLevel: _auth.currentSession == null ? null : level,
        nextLevel: null,
        currentAuthenticationMethods: const [],
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeApi implements ApiClient {
  final calls = <String>[];

  /// JSON body, or an [ApiException] to throw.
  Object? profile = _profile(canEnter: true);
  Object? dashboard;
  void Function()? onGet;

  @override
  Future<T> get<T>(String path, T Function(Object? data) decode, {Map<String, Object?>? query}) async {
    calls.add(path);
    onGet?.call();
    final body = switch (path) {
      '/me/profile' => profile,
      '/admin/dashboard' => dashboard,
      _ => throw StateError('unexpected GET $path'),
    };
    if (body is ApiException) throw body;
    return decode(body);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Map<String, Object?> _profile({required bool canEnter}) => {
  'id': 'user-1',
  'display_name': canEnter ? 'แอดมิน' : 'ลูกค้า',
  'role': canEnter ? 'ADMIN' : 'CUSTOMER',
  'role_label': canEnter ? 'แอดมิน' : 'ลูกค้า',
  'can_enter_backoffice': canEnter,
  'phone_e164': null,
  'banned_at': null,
  'ban_reason': null,
  'avatar_url': null,
};

Factor _factor(String id, FactorStatus status) => Factor(
  id: id,
  friendlyName: 'NightOut Admin',
  factorType: FactorType.totp,
  status: status,
  createdAt: DateTime(2026, 10, 16),
  updatedAt: DateTime(2026, 10, 16),
);

User _user(String email) => User(
  id: 'user-1',
  appMetadata: const {},
  userMetadata: const {},
  aud: 'authenticated',
  email: email,
  createdAt: '2026-10-16T00:00:00Z',
);

Session _sessionFor(String email) => Session(accessToken: 'aal1-token', tokenType: 'bearer', user: _user(email));

Session _session() => _sessionFor(_email);
