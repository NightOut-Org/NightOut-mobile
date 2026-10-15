import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app.color.dart';

abstract final class AppTextStyle {
  static TextStyle _base({
    required double fontSize,
    required double height,
    double? letterSpacing,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.googleSans(
      fontSize: fontSize,
      height: height,
      letterSpacing: letterSpacing,
      fontWeight: fontWeight,
    );
  }

  static final TextStyle display72 = _base(
    fontSize: 72,
    height: 108 / 72,
    letterSpacing: -0.36,
  );
  static final TextStyle display60 = _base(
    fontSize: 60,
    height: 90 / 60,
    letterSpacing: -0.3,
  );
  static final TextStyle display48 = _base(fontSize: 48, height: 70 / 48);
  static final TextStyle display40 = _base(fontSize: 40, height: 60 / 40);
  static final TextStyle display32 = _base(fontSize: 32, height: 48 / 32);
  static final TextStyle heading24 = _base(fontSize: 24, height: 36 / 24);
  static final TextStyle heading20 = _base(
    fontSize: 20,
    height: 30 / 20,
    letterSpacing: 0.03,
  );
  static final TextStyle heading18 = _base(
    fontSize: 18,
    height: 27 / 18,
    letterSpacing: 0.027,
  );
  static final TextStyle body16 = _base(
    fontSize: 16,
    height: 24 / 16,
    letterSpacing: 0.024,
  );
  static final TextStyle body14 = _base(
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0.021,
  );
  static final TextStyle body12 = _base(
    fontSize: 12,
    height: 18 / 12,
    letterSpacing: 0.018,
  );
  static final TextStyle caption10 = _base(
    fontSize: 10,
    height: 16 / 10,
    letterSpacing: 0.025,
  );
  static final TextStyle caption8 = _base(
    fontSize: 8,
    height: 12 / 8,
    letterSpacing: 0.02,
  );

  static TextStyle regular(TextStyle style) => style.copyWith(fontWeight: FontWeight.w400);
  static TextStyle semiBold(TextStyle style) => style.copyWith(fontWeight: FontWeight.w600);
  static TextStyle extraBold(TextStyle style) => style.copyWith(fontWeight: FontWeight.w800);
}

abstract final class AppTheme {
  static final TextStyle text = AppTextStyle.body14;
  static final TextStyle textDark = text.copyWith(color: AppColor.textPrimary);

  static ThemeData theme(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColor.primary,
      primary: AppColor.primary,
      secondary: AppColor.secondary,
      surface: AppColor.surface,
      error: AppColor.danger,
    );

    final textTheme =
        GoogleFonts.notoSansThaiTextTheme(
          TextTheme(
            displayLarge: AppTextStyle.display72,
            displayMedium: AppTextStyle.display60,
            displaySmall: AppTextStyle.display48,
            headlineLarge: AppTextStyle.display40,
            headlineMedium: AppTextStyle.display32,
            headlineSmall: AppTextStyle.heading24,
            titleLarge: AppTextStyle.semiBold(AppTextStyle.heading20),
            titleMedium: AppTextStyle.semiBold(AppTextStyle.heading18),
            titleSmall: AppTextStyle.semiBold(AppTextStyle.body16),
            bodyLarge: AppTextStyle.body16,
            bodyMedium: AppTextStyle.body14,
            bodySmall: AppTextStyle.body12,
            labelLarge: AppTextStyle.semiBold(AppTextStyle.body14),
            labelMedium: AppTextStyle.semiBold(AppTextStyle.body12),
            labelSmall: AppTextStyle.semiBold(AppTextStyle.caption10),
          ),
        ).apply(
          bodyColor: AppColor.textPrimary,
          displayColor: AppColor.textPrimary,
        );

    return ThemeData(
      useMaterial3: true,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      primaryColor: AppColor.primary,
      primarySwatch: AppColor.primary,
      scaffoldBackgroundColor: AppColor.background,
      colorScheme: colorScheme,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColor.surface,
        foregroundColor: AppColor.textPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTextStyle.semiBold(
          AppTextStyle.heading18,
        ).copyWith(color: AppColor.textPrimary),
        elevation: 0,
        centerTitle: false,
      ),
      tabBarTheme: TabBarThemeData(
        labelStyle: AppTextStyle.semiBold(AppTextStyle.body14),
        unselectedLabelStyle: AppTextStyle.regular(AppTextStyle.body14),
        labelColor: AppColor.primary,
        unselectedLabelColor: AppColor.textSecondary,
      ),
      cardTheme: CardThemeData(
        color: AppColor.surface,
        shadowColor: AppColor.neutral200,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      dividerColor: AppColor.border,
      iconTheme: const IconThemeData(color: AppColor.secondary),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColor.primary,
        unselectedItemColor: AppColor.neutral400,
        backgroundColor: AppColor.surface,
        enableFeedback: false,
        showUnselectedLabels: true,
        showSelectedLabels: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(
            AppTextStyle.semiBold(AppTextStyle.body14),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          foregroundColor: const WidgetStatePropertyAll(AppColor.white),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColor.neutral300;
            }
            if (states.contains(WidgetState.pressed)) {
              return AppColor.primary.shade600;
            }
            return AppColor.primary;
          }),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        checkColor: const WidgetStatePropertyAll(AppColor.white),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColor.neutral300;
          }
          if (states.contains(WidgetState.selected)) {
            return AppColor.primary;
          }
          return AppColor.white;
        }),
        side: WidgetStateBorderSide.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return const BorderSide(color: AppColor.neutral300, width: 2);
          }
          return const BorderSide(color: AppColor.primary, width: 2);
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColor.neutral300;
          }
          return AppColor.primary;
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        alignLabelWithHint: true,
        filled: true,
        fillColor: AppColor.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTextStyle.body14.copyWith(color: AppColor.neutral400),
        labelStyle: AppTextStyle.body14.copyWith(color: AppColor.textSecondary),
        errorStyle: AppTextStyle.body12.copyWith(color: AppColor.danger),
        prefixStyle: AppTextStyle.body14.copyWith(color: AppColor.neutral600),
        prefixIconColor: AppColor.neutral400,
        suffixIconColor: AppColor.neutral400,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColor.border),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColor.border),
        ),
        disabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColor.border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColor.primary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColor.danger),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColor.danger, width: 1.5),
        ),
      ),
    );
  }
}
