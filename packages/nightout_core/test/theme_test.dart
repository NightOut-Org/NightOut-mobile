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
}
