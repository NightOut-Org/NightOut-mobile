import 'package:flutter/material.dart';
import 'package:nightout/l10n/app_localizations.dart';

extension ContextExtension on BuildContext {
  double get h {
    return MediaQuery.sizeOf(this).height;
  }

  double get w {
    return MediaQuery.sizeOf(this).width;
  }

  Size get size {
    return MediaQuery.sizeOf(this);
  }

  double get maxWidth {
    if (w > 640) return 640.0;
    return w;
  }

  double get maxWidthPadding {
    if (w <= 640) return 0;
    final padding = (w - 640.0) / 2;
    return padding < 0 ? 0 : padding;
  }

  bool get isTablet {
    return w >= 640;
  }

  TextTheme get textTheme {
    return theme.textTheme;
  }

  ThemeData get theme {
    return Theme.of(this);
  }

  AppLocalizations get t {
    return AppLocalizations.of(this);
  }
}
