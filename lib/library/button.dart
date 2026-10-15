import 'package:flutter/material.dart';
import 'package:nightout/style/app.color.dart';

enum ButtonSize { small, medium, large }

enum ButtonVariant { filled, outlined }

enum ButtonColor { primary, secondary, warning, light, sky, info, transparent, danger, black, pink }

class ButtonTheme {
  static EdgeInsetsGeometry padding(ButtonSize size) {
    EdgeInsetsGeometry data = const EdgeInsets.symmetric(horizontal: 15, vertical: 12);
    if (size == ButtonSize.small) return const EdgeInsets.symmetric(horizontal: 2, vertical: 0);
    if (size == ButtonSize.large) return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    return data;
  }

  static Color textColor(ButtonColor color) {
    Color data = AppColor.primary;
    if (color == ButtonColor.primary) return AppColor.light;
    if (color == ButtonColor.secondary) return AppColor.light;
    if (color == ButtonColor.warning) return AppColor.light;
    if (color == ButtonColor.light) return AppColor.primary;
    if (color == ButtonColor.info) return AppColor.primary;
    if (color == ButtonColor.sky) return AppColor.light;
    if (color == ButtonColor.danger) return AppColor.light;
    if (color == ButtonColor.black) return AppColor.black;
    if (color == ButtonColor.pink) return AppColor.light;
    return data;
  }

  static Color backgroundColor(ButtonColor color) {
    Color data = AppColor.transparent;
    if (color == ButtonColor.primary) return AppColor.primary;
    if (color == ButtonColor.secondary) return AppColor.secondary;
    if (color == ButtonColor.warning) return AppColor.warning;
    if (color == ButtonColor.light) return AppColor.light;
    if (color == ButtonColor.info) return AppColor.primary.shade100;
    if (color == ButtonColor.sky) return AppColor.sky;
    if (color == ButtonColor.danger) return AppColor.danger;
    if (color == ButtonColor.black) return AppColor.black;
    if (color == ButtonColor.pink) return AppColor.pink;
    return data;
  }

  static Color backgroundActionColor(ButtonColor color) {
    Color data = AppColor.transparent;
    if (color == ButtonColor.primary) return AppColor.primary.shade600.withOpacity(0.2);
    if (color == ButtonColor.secondary) return AppColor.secondary.shade600;
    if (color == ButtonColor.warning) return AppColor.warning.shade600;
    if (color == ButtonColor.light) return AppColor.light.shade600;
    if (color == ButtonColor.info) return AppColor.primary.shade300;
    if (color == ButtonColor.sky) return AppColor.sky.shade200;
    if (color == ButtonColor.danger) return AppColor.danger.shade200;
    if (color == ButtonColor.black) return AppColor.black;
    if (color == ButtonColor.pink) return AppColor.black.withOpacity(0.2);
    return data;
  }
}

class Button extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final ButtonColor color;
  final ButtonSize size;
  final Color? textColor;
  final double? elevation;
  final ButtonVariant variant;
  final OutlinedBorder? shape;
  final EdgeInsetsGeometry? padding;

  const Button({
    super.key,
    this.color = ButtonColor.primary,
    this.size = ButtonSize.medium,
    this.variant = ButtonVariant.filled,
    this.textColor,
    this.elevation,
    this.onPressed,
    this.shape,
    this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(padding ?? ButtonTheme.padding(size)),
        elevation: WidgetStateProperty.all(color == ButtonColor.transparent ? 0 : elevation),
        shape: shape == null ? null : WidgetStateProperty.all<OutlinedBorder>(shape!),
        visualDensity: size == ButtonSize.small ? const VisualDensity(vertical: -2) : null,
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (variant == ButtonVariant.outlined) return ButtonTheme.backgroundColor(color);
          if (states.contains(WidgetState.disabled)) {
            if (textColor != null) return textColor!;
            return ButtonTheme.textColor(color);
          } else {
            if (textColor != null) return textColor;
            return ButtonTheme.textColor(color);
          }
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (variant == ButtonVariant.outlined) return AppColor.white;
          if (states.contains(WidgetState.disabled)) {
            return ButtonTheme.backgroundColor(color).withOpacity(0.6);
          } else if (states.contains(WidgetState.pressed)) {
            return ButtonTheme.backgroundColor(color);
          } else {
            return ButtonTheme.backgroundColor(color);
          }
        }),
        shadowColor: WidgetStateProperty.resolveWith((states) {
          if (variant == ButtonVariant.outlined) return AppColor.transparent;
          return null;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return ButtonTheme.backgroundActionColor(color);
          } else if (states.contains(WidgetState.pressed)) {
            return ButtonTheme.backgroundActionColor(color);
          } else {
            if (variant == ButtonVariant.outlined) return AppColor.transparent;
            return ButtonTheme.backgroundActionColor(color);
          }
        }),
        side: WidgetStateProperty.resolveWith((states) {
          if (variant == ButtonVariant.outlined) return BorderSide(color: ButtonTheme.backgroundColor(color));
          return BorderSide.none;
        }),
      ),
      child: child,
    );
  }
}

class ButtonOutline extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final ButtonColor color;
  final ButtonSize size;
  final Color? textColor;
  final double? elevation;
  final double borderWidth;

  const ButtonOutline({
    super.key,
    this.color = ButtonColor.primary,
    this.size = ButtonSize.medium,
    this.borderWidth = 2,
    this.textColor,
    this.elevation,
    this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: ButtonTheme.padding(size),
        elevation: 0,
        visualDensity: size == ButtonSize.small ? const VisualDensity(vertical: -2) : null,
        backgroundColor: AppColor.light,
        foregroundColor: ButtonTheme.backgroundColor(color),
        disabledForegroundColor: ButtonTheme.backgroundColor(color).withOpacity(0.4),
        side: BorderSide(
          width: borderWidth,
          color: onPressed != null
              ? ButtonTheme.backgroundColor(color)
              : ButtonTheme.backgroundColor(color).withOpacity(0.4),
        ),
      ),
      child: child,
    );
  }
}
