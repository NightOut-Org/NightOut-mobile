import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nightout/library/app.navigator.dart';
import 'package:nightout/library/button.dart';
import 'package:nightout/style/app.color.dart';
import 'package:nightout/style/app.theme.dart';
import 'package:nightout/utils/util.dart';

enum AppDialogTyle {
  none,
  success,
  warning,
  light,
}

class AppModalBottom {
  static Color _bgColor(AppDialogTyle type) {
    switch (type) {
      case AppDialogTyle.success:
        return AppColor.success;
      case AppDialogTyle.warning:
        return AppColor.backgroundWorning;
      case AppDialogTyle.light:
      case AppDialogTyle.none:
        return AppColor.light;
    }
  }

  static TextStyle get _titleStyle => AppTextStyle.semiBold(AppTextStyle.heading18);
  static TextStyle get _bodyStyle => AppTextStyle.body16;
  static TextStyle get _buttonStyle => AppTextStyle.semiBold(AppTextStyle.body14);

  static Widget _image(String image) {
    if (image.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 16),
      alignment: Alignment.center,
      child: image.endsWith('.svg') ? SvgPicture.asset(image, width: 100) : Image.asset(image, width: 100),
    );
  }

  static Future<void> alert({
    BuildContext? context,
    AppDialogTyle type = AppDialogTyle.none,
    String bgImage = '',
    bool isClose = false,
    bool enableDrag = false,
    required Widget child,
    Function(dynamic)? finish,
  }) async {
    final ctx = context ?? AppNavigator.context;
    await showModalBottomSheet(
      context: ctx,
      isDismissible: false,
      enableDrag: enableDrag,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColor.transparent,
      builder: (sheetContext) {
        return Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          width: double.infinity,
          alignment: Alignment.bottomCenter,
          child: Container(
            width: Util.maxWidth(sheetContext),
            decoration: BoxDecoration(
              color: _bgColor(type),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: 16,
                right: 20,
                left: 20,
                bottom: MediaQuery.of(sheetContext).padding.bottom + 16,
              ),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  child,
                  if (isClose)
                    Positioned(
                      top: -16,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(sheetContext),
                        child: const Padding(
                          padding: EdgeInsets.only(top: 18, right: 0, left: 10, bottom: 5),
                          child: Icon(
                            Icons.cancel_rounded,
                            color: AppColor.grey,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    ).then(finish ?? (_) {});
  }

  static Future<T?> asyncAlert<T>({
    BuildContext? context,
    AppDialogTyle type = AppDialogTyle.none,
    bool showCloseIcon = false,
    bool enableDrag = false,
    required Widget child,
  }) async {
    final ctx = context ?? AppNavigator.context;
    return showModalBottomSheet<T>(
      context: ctx,
      isDismissible: false,
      enableDrag: enableDrag,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColor.transparent,
      builder: (sheetContext) {
        return Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
          width: double.infinity,
          alignment: Alignment.bottomCenter,
          child: Container(
            width: Util.maxWidth(sheetContext),
            decoration: BoxDecoration(
              color: _bgColor(type),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: 16,
                right: 20,
                left: 20,
                bottom: MediaQuery.of(sheetContext).padding.bottom + 16,
              ),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  child,
                  if (showCloseIcon)
                    Positioned(
                      top: -16,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(sheetContext),
                        child: const Padding(
                          padding: EdgeInsets.only(top: 18, right: 0, left: 10, bottom: 5),
                          child: Icon(
                            Icons.cancel_rounded,
                            color: AppColor.grey,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void confirm({
    BuildContext? context,
    String title = 'แจ้งเตือน',
    String? message,
    String? detail,
    String okText = '',
    String cancelText = '',
    String image = '',
    bool isClose = false,
    Color colorMes = AppColor.black,
    AppDialogTyle type = AppDialogTyle.none,
    Function()? onOk,
    Function()? onCancel,
    Function()? onFinish,
  }) {
    final resolvedOk = okText.isEmpty ? 'ตกลง' : okText;
    final resolvedCancel = cancelText.isEmpty ? 'ยกเลิก' : cancelText;
    final okAction = onOk ?? () {};
    final cancelAction = onCancel ?? () {};

    alert(
      context: context,
      isClose: isClose,
      type: type,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title,
              style: _titleStyle,
              textAlign: TextAlign.center,
            ),
          ),
          image.isNotEmpty ? _image(image) : const SizedBox(height: 10),
          const SizedBox(height: 20),
          if (message != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                message,
                style: _bodyStyle.copyWith(fontSize: 18, color: colorMes),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 10),
          if (detail != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                detail,
                style: _bodyStyle,
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                AppNavigator.back();
                okAction();
              },
              child: Text(resolvedOk, style: _buttonStyle),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ButtonOutline(
              onPressed: () {
                AppNavigator.back();
                cancelAction();
              },
              child: Text(
                resolvedCancel,
                style: _buttonStyle.copyWith(color: AppColor.primary),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
      finish: onFinish != null ? (_) => onFinish() : null,
    );
  }

  static Future<void> success({
    BuildContext? context,
    String title = 'แจ้งเตือน',
    String? message,
    String okText = '',
    String image = 'assets/image/success.svg',
    bool isClose = false,
    ButtonColor color = ButtonColor.primary,
    Function()? onOk,
    Function()? onFinish,
  }) async {
    final resolvedOk = okText.isEmpty ? 'ตกลง' : okText;
    final okAction = onOk ?? () {};

    await alert(
      context: context,
      isClose: isClose,
      type: AppDialogTyle.light,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title,
              style: _titleStyle,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          image.isNotEmpty ? _image(image) : const SizedBox(height: 30),
          const SizedBox(height: 20),
          if (message != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: _bodyStyle.copyWith(fontSize: 18),
              ),
            ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: Button(
              color: color,
              onPressed: () {
                AppNavigator.back();
                okAction();
              },
              child: Text(resolvedOk, style: _buttonStyle),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
      finish: onFinish != null ? (_) => onFinish() : null,
    );
  }

  static void warning({
    BuildContext? context,
    String title = 'แจ้งเตือน',
    String? message,
    String? detail,
    String okText = '',
    String cancelText = '',
    String image = 'assets/image/warningD.svg',
    bool isClose = false,
    Color colorMes = AppColor.black,
    ButtonColor color = ButtonColor.primary,
    Function()? onOk,
    Function()? onFinish,
  }) {
    final resolvedOk = okText.isEmpty ? 'ตกลง' : okText;
    final okAction = onOk ?? () {};

    alert(
      context: context,
      isClose: isClose,
      type: AppDialogTyle.light,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title,
              style: _titleStyle,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          if (image.isNotEmpty) _image(image),
          const SizedBox(height: 20),
          if (message != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                message,
                style: _bodyStyle.copyWith(fontSize: 18, color: colorMes),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 10),
          if (detail != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                detail,
                style: _bodyStyle,
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: Button(
              color: color,
              onPressed: () {
                AppNavigator.back();
                okAction();
              },
              child: Text(resolvedOk, style: _buttonStyle),
            ),
          ),
          const SizedBox(height: 16),
          if (cancelText.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ButtonOutline(
                onPressed: () => AppNavigator.back(),
                child: Text(
                  cancelText,
                  style: _buttonStyle.copyWith(color: AppColor.primary),
                ),
              ),
            ),
        ],
      ),
      finish: onFinish != null ? (_) => onFinish() : null,
    );
  }

  static void error({
    BuildContext? context,
    String title = 'แจ้งเตือน',
    String? message,
    String okText = '',
    String cancelText = '',
    String image = 'assets/image/errorD.svg',
    bool isClose = false,
    Function()? onOk,
    Function()? onFinish,
  }) {
    final resolvedOk = okText.isEmpty ? 'ตกลง' : okText;
    final okAction = onOk ?? () {};

    alert(
      context: context,
      isClose: isClose,
      type: AppDialogTyle.light,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title,
              style: _titleStyle,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          if (image.isNotEmpty) _image(image),
          const SizedBox(height: 20),
          if (message != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                message,
                style: _bodyStyle.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: Button(
              onPressed: () {
                AppNavigator.back();
                okAction();
              },
              child: Text(resolvedOk, style: _buttonStyle),
            ),
          ),
          const SizedBox(height: 16),
          if (cancelText.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ButtonOutline(
                onPressed: () => AppNavigator.back(),
                child: Text(
                  cancelText,
                  style: _buttonStyle.copyWith(color: AppColor.primary),
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
      finish: onFinish != null ? (_) => onFinish() : null,
    );
  }
}
