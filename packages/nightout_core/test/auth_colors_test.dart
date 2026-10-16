import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nightout_core/nightout_core.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final brightness in Brightness.values) {
    test('$brightness theme registers AuthColors', () {
      expect(
        nightOutTheme(brightness).extension<AuthColors>(),
        AuthColors.of(brightness),
      );
    });
  }

  test('auth glass stays dark in light mode, as on the web', () {
    expect(AuthColors.light, same(AuthColors.dark));
  });

  test('values match the web auth modal CSS', () {
    const c = AuthColors.dark;
    // .btn-gold: linear-gradient(180deg, #ffd77a, #e8b64c); color: #1a1206
    expect(c.buttonFrom, const Color(0xFFFFD77A));
    expect(c.buttonTo, NightOutColors.dark.gold);
    expect(c.buttonLabel, const Color(0xFF1A1206));
    // .auth-glass border: rgba(139, 79, 224, 0.55)
    expect(c.glassBorder.a, closeTo(0.55, 0.005));
  });

  testWidgets('context.authColors reads the extension', (tester) async {
    late AuthColors read;
    await tester.pumpWidget(
      MaterialApp(
        theme: nightOutTheme(Brightness.dark),
        home: Builder(
          builder: (context) {
            read = context.authColors;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(read, AuthColors.dark);
  });

  test('NightOutAlpha steps go from faint to strong', () {
    const steps = [
      NightOutAlpha.faint,
      NightOutAlpha.subtle,
      NightOutAlpha.medium,
      NightOutAlpha.strong,
    ];
    expect(steps, orderedEquals([...steps]..sort()));
    expect(steps.every((a) => a > 0 && a < 1), isTrue);
  });
}
