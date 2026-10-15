import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:nightout/extensions/context.extension.dart';
import 'package:nightout/library/app.navigator.dart';
import 'package:nightout/widgets/app/load.widget.dart';

class Loading {
  static Widget init(BuildContext context, Widget? widget) {
    return LoaderOverlay(
      // ignore: deprecated_member_use
      useDefaultLoading: false,
      overlayWidgetBuilder: (_) {
        return Center(
          child: SizedBox(
            height: context.h * 0.045,
            width: context.h * 0.045,
            child: const LoadWidget(),
          ),
        );
      },
      child: widget ?? const SizedBox(),
    );
  }

  static void show() {
    AppNavigator.context.loaderOverlay.show();
  }

  static void close() {
    AppNavigator.context.loaderOverlay.hide();
  }
}
