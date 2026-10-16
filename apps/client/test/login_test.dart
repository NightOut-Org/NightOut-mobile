import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nightout_core/nightout_core.dart';
import 'package:nightout_core/supabase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  const welcome = 'ยินดีต้อนรับกลับ';
  const invalidCredentials = 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';

  testWidgets('empty submit shows both validation messages and does not sign in', (tester) async {
    final auth = FakeAuth();
    await pumpApp(tester, auth: auth);

    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();

    expect(find.text('กรอกอีเมลให้ถูกต้อง'), findsOneWidget);
    expect(find.text('กรอกรหัสผ่าน'), findsOneWidget);
    expect(auth.currentSession, isNull);
  });

  testWidgets('a malformed email is rejected before sign-in', (tester) async {
    final api = FakeApi();
    await pumpApp(tester, auth: FakeAuth(), api: api);

    await tester.signInWith('somchai@test', 'secret123');

    expect(find.text('กรอกอีเมลให้ถูกต้อง'), findsOneWidget);
    expect(find.text('กรอกรหัสผ่าน'), findsNothing);
    expect(api.requests, isEmpty);
  });

  testWidgets('sign-in loads /me/profile and lands on home with the display name', (tester) async {
    final api = FakeApi();
    await pumpApp(tester, auth: FakeAuth(), api: api);

    await tester.signInWith('somchai@test.dev', 'secret123');

    expect(find.text(welcome), findsNothing);
    expect(find.text('สมชาย ทดสอบ'), findsOneWidget);
    expect(find.text('ลูกค้า'), findsOneWidget);
    expect(find.text('somchai@test.dev'), findsOneWidget);
    expect(api.requests, ['/me/profile']);
  });

  testWidgets('invalid credentials stay on login with the web message', (tester) async {
    final api = FakeApi();
    final auth = FakeAuth(
      signInError: const AuthException('Invalid login credentials', statusCode: '400', code: 'invalid_credentials'),
    );
    await pumpApp(tester, auth: auth, api: api);

    await tester.signInWith('somchai@test.dev', 'wrong-password');

    expect(find.text(welcome), findsOneWidget);
    expect(find.text(invalidCredentials), findsOneWidget);
    expect(find.text('Invalid login credentials'), findsNothing);
    expect(api.requests, isEmpty);
  });

  testWidgets('a /me/profile failure after sign-in signs out and shows the API message', (tester) async {
    final auth = FakeAuth();
    await pumpApp(
      tester,
      auth: auth,
      api: FakeApi(error: const ApiException(404, 'USER_NOT_FOUND', 'ไม่พบบัญชีผู้ใช้')),
    );

    await tester.signInWith('somchai@test.dev', 'secret123');

    expect(find.text(welcome), findsOneWidget);
    expect(find.text('ไม่พบบัญชีผู้ใช้'), findsOneWidget);
    expect(auth.signOutCalls, 1);
    expect(auth.currentSession, isNull);
  });

  testWidgets('sign out on home returns to login', (tester) async {
    final auth = FakeAuth(session: fakeSession('somchai@test.dev'));
    await pumpApp(tester, auth: auth);

    await tester.tap(find.text('ออกจากระบบ'));
    await settlePage(tester);

    expect(find.text(welcome), findsOneWidget);
    expect(find.text(invalidCredentials), findsNothing);
    expect(auth.currentSession, isNull);
  });

  testWidgets('sign out still returns to login when the server call fails', (tester) async {
    final auth = FakeAuth(session: fakeSession('somchai@test.dev'))
      ..signOutError = AuthException('ClientException: offline');
    await pumpApp(tester, auth: auth);

    await tester.tap(find.text('ออกจากระบบ'));
    await settlePage(tester);

    expect(find.text(welcome), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a session that expires on home sends the user to login', (tester) async {
    final auth = FakeAuth(session: fakeSession('somchai@test.dev'));
    await pumpApp(tester, auth: auth);
    expect(find.text('สมชาย ทดสอบ'), findsOneWidget);

    auth.expireSession();
    await settlePage(tester);

    expect(find.text(welcome), findsOneWidget);
  });

  testWidgets('the login card stays dark in the light theme, as on the web', (tester) async {
    await pumpApp(tester, auth: FakeAuth(), themeMode: NightOutThemeMode.light);

    final page = tester.element(find.byType(Scaffold));
    final card = tester.element(find.text(welcome));
    expect(Theme.of(page).brightness, Brightness.light);
    expect(Theme.of(card).brightness, Brightness.dark);
  });

  testWidgets('the eye button reveals and hides the password', (tester) async {
    await pumpApp(tester, auth: FakeAuth());
    EditableText password() => tester.widget<EditableText>(
      find.descendant(of: find.byKey(const Key('password-field')), matching: find.byType(EditableText)),
    );

    expect(password().obscureText, isTrue);
    await tester.tap(find.byTooltip('แสดงรหัสผ่าน'));
    await tester.pump();
    expect(password().obscureText, isFalse);
    await tester.tap(find.byTooltip('ซ่อนรหัสผ่าน'));
    await tester.pump();
    expect(password().obscureText, isTrue);
  });
}
