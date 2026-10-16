import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

extension NightOutContext on BuildContext {
  NightOutColors get colors => Theme.of(this).extension<NightOutColors>()!;
}

abstract final class NightOutText {
  static TextStyle sans({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    double? height,
    double? letterSpacing,
    Color? color,
  }) {
    return GoogleFonts.ibmPlexSansThai(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  /// Playfair Display, for English brand headings and bar names.
  static TextStyle display(TextStyle? base, NightOutColors colors) {
    return GoogleFonts.playfairDisplay(
      textStyle: base,
      fontWeight: FontWeight.w700,
      height: 1.15,
      color: colors.text,
    );
  }

  static TextStyle eyebrow(NightOutColors colors) {
    return sans(fontSize: 13, letterSpacing: 13 * 0.14, color: colors.goldText);
  }

  static TextStyle cardTitle(NightOutColors colors) {
    return sans(fontSize: 24, fontWeight: FontWeight.w700, color: colors.text);
  }

  static TextStyle fieldLabel(NightOutColors colors) {
    return sans(fontSize: 13, fontWeight: FontWeight.w600, color: colors.text);
  }
}

ThemeData nightOutTheme(Brightness brightness) {
  final colors = NightOutColors.of(brightness);
  final isDark = brightness == Brightness.dark;
  final sans = GoogleFonts.ibmPlexSansThaiTextTheme().apply(
    bodyColor: colors.text,
    displayColor: colors.text,
  );
  final textTheme = sans.copyWith(
    headlineMedium: NightOutText.display(
      sans.headlineMedium,
      colors,
    ).copyWith(fontSize: 30),
    headlineSmall: NightOutText.sans(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: colors.text,
    ),
    titleLarge: NightOutText.cardTitle(colors),
    bodyMedium: NightOutText.sans(fontSize: 15, color: colors.text),
    bodySmall: NightOutText.sans(fontSize: 13, color: colors.muted),
    labelLarge: NightOutText.sans(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: colors.onGold,
    ),
    labelMedium: NightOutText.fieldLabel(colors),
  );
  final radius = BorderRadius.circular(NightOutRadius.base);
  final overlay = SystemUiOverlayStyle(
    statusBarColor: colors.background,
    statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    statusBarBrightness: brightness,
    systemNavigationBarColor: colors.background,
    systemNavigationBarIconBrightness: isDark
        ? Brightness.light
        : Brightness.dark,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colors.toScheme(brightness),
    scaffoldBackgroundColor: colors.background,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    extensions: [colors],
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.surface,
      foregroundColor: colors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: overlay,
      titleTextStyle: NightOutText.sans(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: colors.text,
      ),
    ),
    cardTheme: CardThemeData(
      color: colors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: colors.border),
      ),
    ),
    dividerColor: colors.border,
    iconTheme: IconThemeData(color: colors.muted),
    chipTheme: ChipThemeData(
      backgroundColor: colors.card,
      selectedColor: colors.purple,
      side: BorderSide(color: colors.border),
      labelStyle: NightOutText.sans(fontSize: 13, color: colors.text),
      secondaryLabelStyle: NightOutText.sans(fontSize: 13, color: Colors.white),
      shape: const StadiumBorder(),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.surface,
      indicatorColor: colors.purple.withValues(alpha: 0.16),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return NightOutText.sans(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? colors.goldText : colors.muted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(color: selected ? colors.goldText : colors.muted);
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.card,
      hintStyle: NightOutText.sans(fontSize: 15, color: colors.muted),
      labelStyle: NightOutText.fieldLabel(colors),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: colors.purple, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: colors.crowdFull),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: colors.crowdFull, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.gold,
        foregroundColor: colors.onGold,
        textStyle: NightOutText.sans(fontSize: 15, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: radius),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.goldText,
        side: BorderSide(color: colors.gold),
        textStyle: NightOutText.sans(fontSize: 15, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: colors.link),
    ),
  );
}
