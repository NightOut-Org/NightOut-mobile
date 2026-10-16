import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nightout_core/nightout_core.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final brightness in Brightness.values) {
    test('$brightness theme maps every web token into ColorScheme', () {
      final theme = nightOutTheme(brightness);
      final colors = NightOutColors.of(brightness);
      final scheme = theme.colorScheme;

      expect(theme.extension<NightOutColors>(), colors);
      expect(theme.scaffoldBackgroundColor, colors.background);
      expect(scheme.brightness, brightness);
      expect(scheme.primary, colors.gold);
      expect(scheme.onPrimary, colors.onGold);
      expect(scheme.secondary, colors.purple);
      expect(scheme.tertiary, colors.link);
      expect(scheme.error, colors.crowdFull);
      expect(scheme.surface, colors.background);
      expect(scheme.onSurface, colors.text);
      expect(scheme.onSurfaceVariant, colors.muted);
      expect(scheme.surfaceContainer, colors.surface);
      expect(scheme.surfaceContainerHigh, colors.card);
      expect(scheme.outline, colors.border);
      expect(scheme.outlineVariant, colors.border);
    });
  }

  test('dark is the default stored theme mode', () {
    expect(NightOutThemeMode.fromStorage(null), NightOutThemeMode.dark);
    expect(NightOutThemeMode.fromStorage('LIGHT'), NightOutThemeMode.light);
    expect(nightOutThemeStorageKey, 'nightout-theme');
  });

  test('sans styles fall back to Noto Sans Thai at the same weight', () {
    final textTheme = nightOutTheme(Brightness.dark).textTheme;
    String noto(FontWeight w) => GoogleFonts.notoSansThai(fontWeight: w).fontFamily!;

    expect(noto(FontWeight.w400), isNot(noto(FontWeight.w700)));
    expect(textTheme.bodyMedium!.fontFamilyFallback, contains(noto(FontWeight.w400)));
    expect(textTheme.titleLarge!.fontWeight, FontWeight.w700);
    expect(textTheme.titleLarge!.fontFamilyFallback, contains(noto(FontWeight.w700)));
    expect(
      NightOutText.sans(fontSize: 13, fontWeight: FontWeight.w600).fontFamilyFallback,
      contains(noto(FontWeight.w600)),
    );
  });

  test('display style falls back to Georgia last', () {
    final style = NightOutText.display(null, NightOutColors.dark);
    expect(style.fontFamilyFallback!.last, 'Georgia');
  });

  test('selected nav item sits on a gold pill like the web BottomIsland', () {
    final colors = NightOutColors.light;
    final nav = nightOutTheme(Brightness.light).navigationBarTheme;
    const selected = {WidgetState.selected};
    const idle = <WidgetState>{};

    expect(nav.indicatorColor, colors.gold);
    expect(nav.iconTheme!.resolve(selected)!.color, colors.onGold);
    expect(nav.labelTextStyle!.resolve(selected)!.color, colors.goldText);
    expect(nav.iconTheme!.resolve(idle)!.color, colors.muted);
    expect(nav.labelTextStyle!.resolve(idle)!.color, colors.muted);
  });
}
