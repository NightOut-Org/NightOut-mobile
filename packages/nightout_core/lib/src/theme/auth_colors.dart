import 'package:flutter/material.dart';

/// Colours of the login / register / forgot-password screens.
///
/// From the web auth modal (`apps/frontend/src/styles/index.css`: `.auth-glass`,
/// `.auth-modal …`, `.btn-gold`). They are not in `tokens.ts`, so they are
/// written here by hand instead of generated into `tokens.g.dart`.
@immutable
class AuthColors extends ThemeExtension<AuthColors> {
  const AuthColors({
    required this.glassFrom,
    required this.glassTo,
    required this.glassBorder,
    required this.glassShadow,
    required this.onGlass,
    required this.onGlassMuted,
    required this.placeholder,
    required this.fieldFill,
    required this.fieldFocusFill,
    required this.fieldFocusBorder,
    required this.fieldFocusRing,
    required this.buttonFrom,
    required this.buttonTo,
    required this.buttonLabel,
    required this.buttonShadow,
  });

  /// `backdrop-filter: blur(18px)` on `.auth-glass`. CSS blur is the Gaussian
  /// standard deviation, the same unit as `ImageFilter.blur` sigma.
  static const glassBlurSigma = 18.0;

  static const dark = AuthColors(
    glassFrom: Color(0xD11A1528),
    glassTo: Color(0xDB0C0A14),
    glassBorder: Color(0x8C8B4FE0),
    glassShadow: [
      BoxShadow(
        color: Color(0x99000000),
        offset: Offset(0, 24),
        blurRadius: 60,
      ),
      BoxShadow(color: Color(0x298B4FE0), blurRadius: 40),
    ],
    onGlass: Color(0xFFFFFFFF),
    onGlassMuted: Color(0x99FFFFFF),
    placeholder: Color(0x66FFFFFF),
    fieldFill: Color(0x12FFFFFF),
    fieldFocusFill: Color(0x1A8B4FE0),
    fieldFocusBorder: Color(0xFF8B4FE0),
    fieldFocusRing: Color(0x408B4FE0),
    buttonFrom: Color(0xFFFFD77A),
    buttonTo: Color(0xFFE8B64C),
    buttonLabel: Color(0xFF1A1206),
    buttonShadow: [
      BoxShadow(
        color: Color(0xA6E8B64C),
        offset: Offset(0, 8),
        blurRadius: 22,
        spreadRadius: -8,
      ),
    ],
  );

  /// The web auth modal is a dark glass card in both themes.
  static const light = dark;

  static AuthColors of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  /// `.auth-glass` background: `linear-gradient(160deg, glassFrom, glassTo)`.
  final Color glassFrom;
  final Color glassTo;
  final Color glassBorder;
  final List<BoxShadow> glassShadow;

  /// Titles and field labels on the glass card.
  final Color onGlass;

  /// Field prefix icons and the footer line.
  final Color onGlassMuted;
  final Color placeholder;
  final Color fieldFill;
  final Color fieldFocusFill;
  final Color fieldFocusBorder;

  /// 3 px focus ring around a field (`box-shadow: 0 0 0 3px`).
  final Color fieldFocusRing;

  /// `.btn-gold` background: `linear-gradient(180deg, buttonFrom, buttonTo)`.
  final Color buttonFrom;
  final Color buttonTo;
  final Color buttonLabel;
  final List<BoxShadow> buttonShadow;

  @override
  AuthColors copyWith({
    Color? glassFrom,
    Color? glassTo,
    Color? glassBorder,
    List<BoxShadow>? glassShadow,
    Color? onGlass,
    Color? onGlassMuted,
    Color? placeholder,
    Color? fieldFill,
    Color? fieldFocusFill,
    Color? fieldFocusBorder,
    Color? fieldFocusRing,
    Color? buttonFrom,
    Color? buttonTo,
    Color? buttonLabel,
    List<BoxShadow>? buttonShadow,
  }) {
    return AuthColors(
      glassFrom: glassFrom ?? this.glassFrom,
      glassTo: glassTo ?? this.glassTo,
      glassBorder: glassBorder ?? this.glassBorder,
      glassShadow: glassShadow ?? this.glassShadow,
      onGlass: onGlass ?? this.onGlass,
      onGlassMuted: onGlassMuted ?? this.onGlassMuted,
      placeholder: placeholder ?? this.placeholder,
      fieldFill: fieldFill ?? this.fieldFill,
      fieldFocusFill: fieldFocusFill ?? this.fieldFocusFill,
      fieldFocusBorder: fieldFocusBorder ?? this.fieldFocusBorder,
      fieldFocusRing: fieldFocusRing ?? this.fieldFocusRing,
      buttonFrom: buttonFrom ?? this.buttonFrom,
      buttonTo: buttonTo ?? this.buttonTo,
      buttonLabel: buttonLabel ?? this.buttonLabel,
      buttonShadow: buttonShadow ?? this.buttonShadow,
    );
  }

  @override
  AuthColors lerp(AuthColors? other, double t) {
    if (other == null) return this;
    return AuthColors(
      glassFrom: Color.lerp(glassFrom, other.glassFrom, t)!,
      glassTo: Color.lerp(glassTo, other.glassTo, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      glassShadow:
          BoxShadow.lerpList(glassShadow, other.glassShadow, t) ?? glassShadow,
      onGlass: Color.lerp(onGlass, other.onGlass, t)!,
      onGlassMuted: Color.lerp(onGlassMuted, other.onGlassMuted, t)!,
      placeholder: Color.lerp(placeholder, other.placeholder, t)!,
      fieldFill: Color.lerp(fieldFill, other.fieldFill, t)!,
      fieldFocusFill: Color.lerp(fieldFocusFill, other.fieldFocusFill, t)!,
      fieldFocusBorder: Color.lerp(
        fieldFocusBorder,
        other.fieldFocusBorder,
        t,
      )!,
      fieldFocusRing: Color.lerp(fieldFocusRing, other.fieldFocusRing, t)!,
      buttonFrom: Color.lerp(buttonFrom, other.buttonFrom, t)!,
      buttonTo: Color.lerp(buttonTo, other.buttonTo, t)!,
      buttonLabel: Color.lerp(buttonLabel, other.buttonLabel, t)!,
      buttonShadow:
          BoxShadow.lerpList(buttonShadow, other.buttonShadow, t) ??
          buttonShadow,
    );
  }
}
