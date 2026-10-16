import 'package:flutter/material.dart';

part 'tokens.g.dart';

abstract final class NightOutMotion {
  static const fast = _fast;
  static const base = _base;
  static const slow = _slow;
  static const easeOut = _easeOut;
  static const sheetStiffness = _sheetStiffness;
  static const sheetDamping = _sheetDamping;

  // Mobile-only: web has these in component CSS, not in tokens.ts.
  static const themeFade = Duration(milliseconds: 300);
  static const pressedScale = 0.98;
}

abstract final class NightOutRadius {
  static const base = _radiusBase;
  static const pill = _radiusPill;

  // Mobile-only: web has this in the auth page CSS, not in tokens.ts.
  static const authGlass = 24.0;
}

/// Opacity steps for tinting a token, like the web's Tailwind `purple/45`:
/// `colors.purple.withValues(alpha: NightOutAlpha.medium)`.
/// Mobile-only: web writes the number inline in each class name.
abstract final class NightOutAlpha {
  /// Barely-there fill: `bg-grey/5` on the auth card.
  static const faint = 0.05;

  /// Tinted background behind a coloured border or text, e.g. an error box.
  static const subtle = 0.12;

  /// Soft border or glow: `border-purple/45`.
  static const medium = 0.45;

  /// Strong overlay on photos: `bg-black/65`.
  static const strong = 0.65;
}

/// Bar tier badge colours. Customers see stars; Backoffice charts use these.
enum NightOutTier {
  s(_tierS),
  a(_tierA),
  b(_tierB),
  c(_tierC);

  const NightOutTier(this._token);

  final ({Color background, Color foreground, String label}) _token;

  Color get background => _token.background;
  Color get foreground => _token.foreground;
  String get label => _token.label;
}

@immutable
class NightOutColors extends ThemeExtension<NightOutColors> {
  const NightOutColors({
    required this.background,
    required this.surface,
    required this.card,
    required this.border,
    required this.text,
    required this.muted,
    required this.gold,
    required this.goldHighlight,
    required this.goldText,
    required this.onGold,
    required this.purple,
    required this.link,
    required this.crowdAvailable,
    required this.crowdAlmostFull,
    required this.crowdFull,
    required this.heroVia,
    required this.titleFrom,
    required this.titleTo,
    required this.glow,
  });

  static const dark = _dark;
  static const light = _light;

  static NightOutColors of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  final Color background;
  final Color surface;
  final Color card;
  final Color border;
  final Color text;
  final Color muted;
  final Color gold;
  final Color goldHighlight;
  final Color goldText;
  final Color onGold;
  final Color purple;
  final Color link;
  final Color crowdAvailable;
  final Color crowdAlmostFull;
  final Color crowdFull;
  final Color heroVia;
  final Color titleFrom;
  final Color titleTo;
  final List<BoxShadow> glow;

  ColorScheme toScheme(Brightness brightness) {
    return ColorScheme.fromSeed(
      seedColor: gold,
      brightness: brightness,
    ).copyWith(
      primary: gold,
      onPrimary: onGold,
      secondary: purple,
      onSecondary: Colors.white,
      tertiary: link,
      onTertiary: brightness == Brightness.dark ? background : Colors.white,
      error: crowdFull,
      onError: Colors.white,
      surface: background,
      onSurface: text,
      onSurfaceVariant: muted,
      surfaceContainer: surface,
      surfaceContainerHigh: card,
      surfaceContainerHighest: card,
      outline: border,
      outlineVariant: border,
    );
  }

  @override
  NightOutColors copyWith({
    Color? background,
    Color? surface,
    Color? card,
    Color? border,
    Color? text,
    Color? muted,
    Color? gold,
    Color? goldHighlight,
    Color? goldText,
    Color? onGold,
    Color? purple,
    Color? link,
    Color? crowdAvailable,
    Color? crowdAlmostFull,
    Color? crowdFull,
    Color? heroVia,
    Color? titleFrom,
    Color? titleTo,
    List<BoxShadow>? glow,
  }) {
    return NightOutColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      border: border ?? this.border,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      gold: gold ?? this.gold,
      goldHighlight: goldHighlight ?? this.goldHighlight,
      goldText: goldText ?? this.goldText,
      onGold: onGold ?? this.onGold,
      purple: purple ?? this.purple,
      link: link ?? this.link,
      crowdAvailable: crowdAvailable ?? this.crowdAvailable,
      crowdAlmostFull: crowdAlmostFull ?? this.crowdAlmostFull,
      crowdFull: crowdFull ?? this.crowdFull,
      heroVia: heroVia ?? this.heroVia,
      titleFrom: titleFrom ?? this.titleFrom,
      titleTo: titleTo ?? this.titleTo,
      glow: glow ?? this.glow,
    );
  }

  @override
  NightOutColors lerp(NightOutColors? other, double t) {
    if (other == null) return this;
    return NightOutColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      goldHighlight: Color.lerp(goldHighlight, other.goldHighlight, t)!,
      goldText: Color.lerp(goldText, other.goldText, t)!,
      onGold: Color.lerp(onGold, other.onGold, t)!,
      purple: Color.lerp(purple, other.purple, t)!,
      link: Color.lerp(link, other.link, t)!,
      crowdAvailable: Color.lerp(crowdAvailable, other.crowdAvailable, t)!,
      crowdAlmostFull: Color.lerp(crowdAlmostFull, other.crowdAlmostFull, t)!,
      crowdFull: Color.lerp(crowdFull, other.crowdFull, t)!,
      heroVia: Color.lerp(heroVia, other.heroVia, t)!,
      titleFrom: Color.lerp(titleFrom, other.titleFrom, t)!,
      titleTo: Color.lerp(titleTo, other.titleTo, t)!,
      glow: BoxShadow.lerpList(glow, other.glow, t) ?? glow,
    );
  }
}
