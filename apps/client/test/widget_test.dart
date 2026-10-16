import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nightout_core/nightout_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('splash opens login when there is no session', (tester) async {
    await pumpApp(tester, auth: FakeAuth());
    expect(find.text('ยินดีต้อนรับกลับ'), findsOneWidget);
  });

  testWidgets('splash restores a stored session and opens home with the profile', (tester) async {
    final api = FakeApi();
    await pumpApp(
      tester,
      auth: FakeAuth(session: fakeSession('somchai@test.dev')),
      api: api,
    );
    expect(find.text('สมชาย ทดสอบ'), findsOneWidget);
    expect(find.text('ลูกค้า'), findsOneWidget);
    expect(find.text('somchai@test.dev'), findsOneWidget);
    expect(api.requests, ['/me/profile']);
  });

  testWidgets('a stored session whose profile fails opens login and keeps the session', (tester) async {
    final auth = FakeAuth(session: fakeSession('somchai@test.dev'));
    await pumpApp(
      tester,
      auth: auth,
      api: FakeApi(error: const ApiException(0, 'ติดต่อเซิร์ฟเวอร์ไม่ได้', null)),
    );
    expect(find.text('ยินดีต้อนรับกลับ'), findsOneWidget);
    expect(find.text('ติดต่อเซิร์ฟเวอร์ไม่ได้'), findsOneWidget);
    expect(auth.signOutCalls, 0);
    expect(auth.currentSession, isNotNull);
  });

  testWidgets('home starts dark and switches to light from the theme menu', (tester) async {
    await pumpApp(tester, auth: FakeAuth(session: fakeSession('somchai@test.dev')));
    final home = find.text('สมชาย ทดสอบ');
    expect(Theme.of(tester.element(home)).brightness, Brightness.dark);

    await tester.tap(find.byTooltip('ธีม'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(NightOutThemeMode.light.label).last);
    await tester.pumpAndSettle();

    expect(Theme.of(tester.element(home)).brightness, Brightness.light);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(nightOutThemeStorageKey), 'LIGHT');
  });
}
