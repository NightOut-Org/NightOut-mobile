import 'package:flutter/widgets.dart';

import 'theme/tokens.dart';

extension NightOutMotionContext on BuildContext {
  /// The device's reduce-motion setting. When true, skip the animation or use
  /// a [NightOutMotion.fast] fade, as the web does.
  bool get reduceMotion => MediaQuery.disableAnimationsOf(this);

  /// For `MaterialApp.themeAnimationDuration`: the 300 ms fade, or an instant
  /// switch under reduced motion. `View` puts a MediaQuery above MaterialApp.
  Duration get themeFadeDuration =>
      reduceMotion ? Duration.zero : NightOutMotion.themeFade;
}
