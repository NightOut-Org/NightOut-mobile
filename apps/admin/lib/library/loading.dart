import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:nightoutadmin/extensions/context.extension.dart';
import 'package:nightoutadmin/library/app.navigator.dart';
import 'package:nightout_core/nightout_core.dart';

class Loading {
  static Widget init(BuildContext context, Widget? widget) {
    return LoaderOverlay(
      overlayWidgetBuilder: (_) {
        return Center(
          child: SizedBox.square(
            dimension: context.h * 0.045,
            child: const LoadWidget(),
          ),
        );
      },
      child: widget ?? const SizedBox.shrink(),
    );
  }

  static void show() {
    AppNavigator.context.loaderOverlay.show();
  }

  static void close() {
    AppNavigator.context.loaderOverlay.hide();
  }
}
