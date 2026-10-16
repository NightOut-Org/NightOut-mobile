import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nightout_core/nightout_core.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pump(WidgetTester tester, Widget child) {
    return tester.pumpWidget(
      MaterialApp(
        theme: nightOutTheme(Brightness.dark),
        home: Scaffold(body: child),
      ),
    );
  }

  testWidgets('gradient replaces the text colour', (tester) async {
    await pump(tester, const GradientTitle('NightOut'));

    final mask = tester.widget<ShaderMask>(find.byType(ShaderMask));
    expect(mask.blendMode, BlendMode.srcIn);

    final style = tester.widget<Text>(find.text('NightOut')).style!;
    expect(style.fontSize, 30);
    expect(style.fontFamily, contains('PlayfairDisplay'));
  });

  testWidgets('hero size is 36', (tester) async {
    await pump(
      tester,
      const GradientTitle('Admin Pass', size: GradientTitleSize.hero),
    );

    expect(tester.widget<Text>(find.text('Admin Pass')).style!.fontSize, 36);
  });
}
