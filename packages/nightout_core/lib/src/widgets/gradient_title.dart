import 'package:flutter/material.dart';

import '../theme/theme.dart';

enum GradientTitleSize {
  /// Theme `headlineMedium` (30): splash screens, page headers.
  page,

  /// 36: the admin login heading.
  hero,
}

/// English brand heading in Playfair Display, filled with the gold
/// `titleFrom` → `titleTo` gradient, like the web's gradient titles.
class GradientTitle extends StatelessWidget {
  const GradientTitle(
    this.text, {
    super.key,
    this.size = GradientTitleSize.page,
    this.textAlign,
  });

  static const _heroFontSize = 36.0;

  final String text;
  final GradientTitleSize size;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = NightOutText.display(
      Theme.of(context).textTheme.headlineMedium,
      colors,
    );

    return ShaderMask(
      // srcIn paints the gradient wherever the text is and ignores the text
      // colour, so the text needs no special colour of its own.
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        colors: [colors.titleFrom, colors.titleTo],
      ).createShader(bounds),
      child: Text(
        text,
        textAlign: textAlign,
        style: switch (size) {
          GradientTitleSize.page => style,
          GradientTitleSize.hero => style.copyWith(fontSize: _heroFontSize),
        },
      ),
    );
  }
}
