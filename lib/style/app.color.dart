import 'package:flutter/material.dart';

abstract final class AppColor {
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);

  /// Coral — Primary
  static const MaterialColor primary = MaterialColor(0xFFFF8957, {
    50: Color(0xFFFFF3EE),
    100: Color(0xFFFFE7DD),
    200: Color(0xFFFFCFBB),
    300: Color(0xFFFFB89A),
    400: Color(0xFFFFA078),
    500: Color(0xFFFF8957),
    600: Color(0xFFE47443),
    700: Color(0xFFD36C40),
    800: Color(0xFFB45B35),
    900: Color(0xFF9D5738),
  });

  /// Azure Radiance — Secondary
  static const MaterialColor secondary = MaterialColor(0xFF4A6ED9, {
    50: Color(0xFFE8F0FD),
    100: Color(0xFFD3DEF5),
    200: Color(0xFFB4C5EE),
    300: Color(0xFF90ACE9),
    400: Color(0xFF6E90E0),
    500: Color(0xFF4A6ED9),
    600: Color(0xFF4263C3),
    700: Color(0xFF3B58AD),
    800: Color(0xFF2C4282),
    900: Color(0xFF25376C),
  });

  /// Oslo Gray — Neutral
  static const MaterialColor neutral = MaterialColor(0xFF7E8892, {
    50: Color(0xFFF4F6F7),
    100: Color(0xFFE3E6EA),
    200: Color(0xFFCCD1D5),
    300: Color(0xFFA9B0B7),
    400: Color(0xFF939CA4),
    500: Color(0xFF7E8892),
    600: Color(0xFF636C77),
    700: Color(0xFF4B5158),
    800: Color(0xFF373C41),
    900: Color(0xFF232529),
  });

  /// Curious Blue — Info
  static const MaterialColor info = MaterialColor(0xFF579CEE, {
    50: Color(0xFFE6F3FE),
    100: Color(0xFFD2E7FB),
    200: Color(0xFFBBDBF8),
    300: Color(0xFFA0C9F4),
    400: Color(0xFF78B2F1),
    500: Color(0xFF579CEE),
    600: Color(0xFF518ED3),
    700: Color(0xFF387CCC),
    800: Color(0xFF2A67B0),
    900: Color(0xFF275388),
  });

  /// Asparagus — Success
  static const MaterialColor success = MaterialColor(0xFF5AB89D, {
    50: Color(0xFFE9F9F5),
    100: Color(0xFFDCF2EC),
    200: Color(0xFFBDE2D7),
    300: Color(0xFF9CD4C4),
    400: Color(0xFF7AC6B0),
    500: Color(0xFF5AB89D),
    600: Color(0xFF48937D),
    700: Color(0xFF3E806D),
    800: Color(0xFF366E5E),
    900: Color(0xFF24493E),
  });

  /// Mandy — Danger
  static const MaterialColor danger = MaterialColor(0xFFD92549, {
    50: Color(0xFFFFF3F4),
    100: Color(0xFFFFE3E7),
    200: Color(0xFFFACAD1),
    300: Color(0xFFFCA2B0),
    400: Color(0xFFF77F91),
    500: Color(0xFFD92549),
    600: Color(0xFFD92549),
    700: Color(0xFFB7193C),
    800: Color(0xFF991839),
    900: Color(0xFF831837),
  });

  /// Zest — Warning
  static const MaterialColor warning = MaterialColor(0xFFFF9D2B, {
    50: Color(0xFFFFF7EB),
    100: Color(0xFFFFEAC6),
    200: Color(0xFFFFD391),
    300: Color(0xFFFEBB70),
    400: Color(0xFFFDAD51),
    500: Color(0xFFFF9D2B),
    600: Color(0xFFE07416),
    700: Color(0xFFB95915),
    800: Color(0xFF944618),
    900: Color(0xFF682A09),
  });

  // Semantic colors
  static const Color background = neutral50;
  static const Color surface = white;
  static const Color textPrimary = neutral900;
  static const Color textSecondary = neutral600;
  static const Color border = neutral200;
  static const Color disabled = neutral300;
  static const Color selected = Color(0xFFD3DEF5);
  static const Color link = Color(0xFF4263C3);
  static const Color linkLight = Color(0xFFD3DEF5);
  static const Color bgWarning = Color(0xFFFFF7EB);
  static const Color bgInfo = Color(0xFFE6F3FE);
  static const Color bgSuccess = Color(0xFFE9F9F5);
  static const Color backgroundEmpty = neutral50;

  // Frequently used token aliases
  static const Color neutral50 = Color(0xFFF4F6F7);
  static const Color neutral100 = Color(0xFFE3E6EA);
  static const Color neutral200 = Color(0xFFCCD1D5);
  static const Color neutral300 = Color(0xFFA9B0B7);
  static const Color neutral400 = Color(0xFF939CA4);
  static const Color neutral500 = Color(0xFF7E8892);
  static const Color neutral600 = Color(0xFF636C77);
  static const Color neutral700 = Color(0xFF4B5158);
  static const Color neutral800 = Color(0xFF373C41);
  static const Color neutral900 = Color(0xFF232529);

  // Backward-compatible aliases
  static const MaterialColor grey = neutral;
  static const MaterialColor dark = neutral;

  static const MaterialColor light = MaterialColor(0xFFFFFFFF, {
    50: Color(0xFFFFFFFF),
    100: Color(0xFFFFFFFF),
    200: Color(0xFFFFFFFF),
    300: Color(0xFFFFFFFF),
    400: Color(0xFFFFFFFF),
    500: Color(0xFFFFFFFF),
    600: Color(0xFFF4F6F7),
    700: Color(0xFFE3E6EA),
    800: Color(0xFFCCD1D5),
    900: Color(0xFFA9B0B7),
  });
  static const MaterialColor sky = info;
  static const MaterialColor cyan = info;
  static const MaterialColor pink = danger;
  static const Color darkGrey = neutral500;
  static const Color skyBlue = Color(0xFF579CEE);
  static const Color backgroundWorning = Color(0xFFFFEAC6);

  static Color hex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
