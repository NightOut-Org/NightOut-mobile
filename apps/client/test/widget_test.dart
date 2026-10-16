import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nightout/app.dart';
import 'package:nightout_core/nightout_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> openHome(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    expect(find.text('Nightout'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // page transition
  }

  testWidgets('splash opens home', (tester) async {
    await openHome(tester);
    expect(find.text('ไปหน้า Login'), findsOneWidget);
  });

  testWidgets('home starts dark and switches to light from the theme menu', (tester) async {
    await openHome(tester);
    final home = find.text('ไปหน้า Login');
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
