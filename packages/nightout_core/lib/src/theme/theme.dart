import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth_colors.dart';
import 'tokens.dart';

extension NightOutContext on BuildContext {
  NightOutColors get colors => Theme.of(this).extension<NightOutColors>()!;
  AuthColors get authColors => Theme.of(this).extension<AuthColors>()!;
}

abstract final class NightOutText {
  static TextStyle sans({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    double? height,
    double? letterSpacing,
    Color? color,
  }) {
    return _withThaiFallback(
      GoogleFonts.ibmPlexSansThai(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      ),
    );
  }

  /// Playfair Display, for English brand headings and bar names.
  static TextStyle display(TextStyle? base, NightOutColors colors) {
    final style = GoogleFonts.playfairDisplay(
      textStyle: base,
      fontWeight: FontWeight.w700,
      height: 1.15,
      color: colors.text,
    );
    return style.copyWith(
      fontFamilyFallback: [...?style.fontFamilyFallback, 'Georgia'],
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

/// IBM Plex Sans Thai → Noto Sans Thai → system, as on the web.
///
/// google_fonts registers each weight as its own family (`NotoSansThai_700`)
/// and sets `fontFamilyFallback` itself, so the fallback is added afterwards
/// with the Noto family that matches this style's weight.
TextStyle _withThaiFallback(TextStyle style) {
  final weight = style.fontWeight ?? FontWeight.w400;
  final noto = GoogleFonts.notoSansThai(fontWeight: weight);
  return style.copyWith(
    fontFamilyFallback: [
      ...?style.fontFamilyFallback,
      noto.fontFamily!,
      ...?noto.fontFamilyFallback,
    ],
  );
}

TextTheme _sansTextTheme(TextTheme t) {
  TextStyle? f(TextStyle? style) => style == null ? null : _withThaiFallback(style);
  return TextTheme(
    displayLarge: f(t.displayLarge),
    displayMedium: f(t.displayMedium),
    displaySmall: f(t.displaySmall),
    headlineLarge: f(t.headlineLarge),
    headlineMedium: f(t.headlineMedium),
    headlineSmall: f(t.headlineSmall),
    titleLarge: f(t.titleLarge),
    titleMedium: f(t.titleMedium),
    titleSmall: f(t.titleSmall),
    bodyLarge: f(t.bodyLarge),
    bodyMedium: f(t.bodyMedium),
    bodySmall: f(t.bodySmall),
    labelLarge: f(t.labelLarge),
    labelMedium: f(t.labelMedium),
    labelSmall: f(t.labelSmall),
  );
}

ThemeData nightOutTheme(Brightness brightness) {
  final colors = NightOutColors.of(brightness);
  final isDark = brightness == Brightness.dark;
  final sans = _sansTextTheme(
    GoogleFonts.ibmPlexSansThaiTextTheme(),
  ).apply(bodyColor: colors.text, displayColor: colors.text);
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
    extensions: [colors, AuthColors.of(brightness)],
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
    // Web BottomIsland (apps/frontend/src/ui/components/navbar.tsx): the
    // selected item sits on a solid gold pill. Material draws the label outside
    // the indicator, so the selected label is goldText, not onGold.
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.surface,
      indicatorColor: colors.gold,
      indicatorShape: const StadiumBorder(),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return NightOutText.sans(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? colors.goldText : colors.muted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 20,
          color: selected ? colors.onGold : colors.muted,
        );
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
