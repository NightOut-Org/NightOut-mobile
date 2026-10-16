import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nightout/library/app.navigator.dart';
import 'package:nightout/screen/home/home.page.dart';
import 'package:nightout/screen/login/login.page.dart';
import 'package:nightout/screen/register/register.page.dart';
import 'package:nightout/screen/splash.screen.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const home = '/home';
  static const login = '/login';
  static const register = '/register';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: AppNavigator.key,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: kDebugMode,
    observers: [
      AppNavigator.routeObserver,
    ],
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
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('ไม่พบหน้า: ${state.uri}'),
      ),
    ),
  );
});
