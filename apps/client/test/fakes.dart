import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nightout/app.dart';
import 'package:nightout/modules/api/api.provider.dart';
import 'package:nightout_core/nightout_core.dart';

Session fakeSession(String email) => Session(
  accessToken: 'test-access-token',
  tokenType: 'bearer',
  user: User(
    id: 'user-1',
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    createdAt: '2026-10-16T00:00:00Z',
    email: email,
  ),
);

/// Emits auth events the way supabase_flutter does, so the controller's
/// listener runs in tests.
class FakeAuth implements GoTrueClient {
  FakeAuth({Session? session, this.signInError}) : _session = session;

  Session? _session;
  final AuthException? signInError;
  final _events = StreamController<AuthState>.broadcast();
  int signOutCalls = 0;

  @override
  Session? get currentSession => _session;

  @override
  Future<Session?> getSession() async => _session;

  @override
  Stream<AuthState> get onAuthStateChange => _events.stream;

  @override
  Future<AuthResponse> signInWithPassword({
    String? email,
    String? phone,
    required String password,
    String? captchaToken,
  }) async {
    if (signInError case final error?) throw error;
    final session = _session = fakeSession(email!);
    _events.add(AuthState(AuthChangeEvent.signedIn, session));
    return AuthResponse(session: session);
  }

  /// Like gotrue: the local session goes first, then the server call can fail.
  AuthException? signOutError;

  @override
  Future<void> signOut({Object? scope}) async {
    signOutCalls++;
    expireSession();
    if (signOutError case final error?) throw error;
  }

  /// What supabase_flutter does when the refresh token stops working.
  void expireSession() {
    _session = null;
    _events.add(AuthState(AuthChangeEvent.signedOut, null));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Answers `GET /me/profile` with [profile], or throws [error].
class FakeApi implements ApiClient {
  FakeApi({this.profile = customerProfile, this.error});

  static const customerProfile = <String, Object?>{
    'id': 'user-1',
    'display_name': 'สมชาย ทดสอบ',
    'role': 'CUSTOMER',
    'role_label': 'ลูกค้า',
    'can_enter_backoffice': false,
    'phone_e164': null,
    'banned_at': null,
    'ban_reason': null,
    'avatar_url': null,
  };

  final Map<String, Object?> profile;
  final ApiException? error;
  final requests = <String>[];

  @override
  Future<T> get<T>(
    String path,
    T Function(Object? data) decode, {
    Map<String, Object?>? query,
  }) async {
    requests.add(path);
    if (error case final error?) throw error;
    if (path != '/me/profile') throw StateError('unexpected GET $path');
    return decode(profile);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Pumps the app and waits out the splash (800 ms) and the page transition.
Future<void> pumpApp(
  WidgetTester tester, {
  required FakeAuth auth,
  FakeApi? api,
  NightOutThemeMode themeMode = NightOutThemeMode.dark,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        supabaseAuthProvider.overrideWithValue(auth),
        apiClientProvider.overrideWithValue(api ?? FakeApi()),
        nightOutInitialThemeModeProvider.overrideWithValue(themeMode),
      ],
      child: const App(),
    ),
  );
  expect(find.text('Nightout'), findsOneWidget);
  await tester.pump(const Duration(milliseconds: 900));
  await settlePage(tester);
}

/// Lets futures resolve, then finishes a route transition. Not pumpAndSettle:
/// the splash and button spinners repeat forever.
Future<void> settlePage(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

extension LoginForm on WidgetTester {
  Future<void> signInWith(String email, String password) async {
    await enterText(
      find.descendant(of: find.byKey(const Key('email-field')), matching: find.byType(EditableText)),
      email,
    );
    await enterText(
      find.descendant(of: find.byKey(const Key('password-field')), matching: find.byType(EditableText)),
      password,
    );
    await tap(find.byKey(const Key('login-submit')));
    await settlePage(this);
  }
}
