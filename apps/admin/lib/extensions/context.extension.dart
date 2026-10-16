import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  double get h => MediaQuery.sizeOf(this).height;

  double get w => MediaQuery.sizeOf(this).width;

  Size get size => MediaQuery.sizeOf(this);

  double get maxWidth => w > 640 ? 640 : w;

  double get maxWidthPadding {
    if (w <= 640) return 0;
    final padding = (w - 640) / 2;
    return padding < 0 ? 0 : padding;
  }

  bool get isTablet => w >= 640;

  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;
}
