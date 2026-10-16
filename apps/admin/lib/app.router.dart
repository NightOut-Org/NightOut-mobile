import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nightoutadmin/library/app.navigator.dart';
import 'package:nightoutadmin/modules/controller/auth.ctrl.dart';
import 'package:nightoutadmin/screen/home/home.page.dart';
import 'package:nightoutadmin/screen/login/login.page.dart';
import 'package:nightoutadmin/screen/splash.screen.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const login = '/login';
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authCtrl, (_, _) => refresh.value++);

  final router = GoRouter(
    navigatorKey: AppNavigator.key,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: refresh,
    observers: [AppNavigator.routeObserver],
    redirect: (context, state) {
      final auth = ref.read(authCtrl);
      final location = state.matchedLocation;
      if (location == AppRoutes.splash) return null;
      if (location == AppRoutes.home && !auth.isSignedIn) return AppRoutes.login;
      if (location == AppRoutes.login && auth.isSignedIn) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
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
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
