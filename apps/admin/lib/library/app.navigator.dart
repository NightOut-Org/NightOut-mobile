import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ใช้กับ dialog และ bottom sheet
/// การเปลี่ยนหน้าใช้ go_router: context.go / context.push / context.pop
class AppNavigator {
  AppNavigator._();

  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();
  static final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

  static BuildContext get context {
    final ctx = key.currentContext;
    assert(ctx != null, 'AppNavigator ยังไม่พร้อม — ผูก navigatorKey กับ GoRouter แล้วหรือยัง');
    return ctx!;
  }

  static NavigatorState get state {
    final nav = key.currentState;
    assert(nav != null, 'AppNavigator ยังไม่พร้อม — ผูก navigatorKey กับ GoRouter แล้วหรือยัง');
    return nav!;
  }

  static void back<T extends Object?>([T? result]) {
    if (state.canPop()) state.pop(result);
  }
}

final rootNavigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) => AppNavigator.key);
