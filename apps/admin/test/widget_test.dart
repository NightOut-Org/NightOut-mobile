import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nightoutadmin/app.dart';
import 'package:nightout_core/nightout_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('เปิดหน้าแอดมินด้วยธีมมืด แล้วสลับเป็นสว่างได้', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [supabaseAuthProvider.overrideWithValue(_SignedOutAuth())],
        child: const App(),
      ),
    );
    await tester.pump();
    expect(find.byType(LoadWidget), findsOneWidget);
    expect(find.text('NightOut'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Admin Pass'), findsOneWidget);

    final darkScaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(darkScaffold.backgroundColor, NightOutColors.dark.background);

    await tester.tap(find.byTooltip('ธีม'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('สว่าง').last);
    await tester.pumpAndSettle();

    final lightScaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(lightScaffold.backgroundColor, NightOutColors.light.background);
  });
}

class _SignedOutAuth implements GoTrueClient {
  @override
  Session? get currentSession => null;

  @override
  Future<Session?> getSession() async => null;

  @override
  Stream<AuthState> get onAuthStateChange => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
