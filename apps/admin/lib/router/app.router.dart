import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nightoutadmin/library/app.navigator.dart';
import 'package:nightoutadmin/screen/home/home.page.dart';
import 'package:nightoutadmin/screen/splash.screen.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const home = '/home';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: AppNavigator.key,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: kDebugMode,
    observers: [AppNavigator.routeObserver],
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('ไม่พบหน้า: ${state.uri}')),
    ),
  );
});
