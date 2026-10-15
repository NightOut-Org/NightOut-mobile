import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nightout/library/app.navigator.dart';
import 'package:nightout/router/app.router.dart';

class AppCtrlState {
  const AppCtrlState({
    this.error = '',
    this.authenticated = false,
  });

  final String error;
  final bool authenticated;

  AppCtrlState copyWith({
    String? error,
    bool? authenticated,
  }) {
    return AppCtrlState(
      error: error ?? this.error,
      authenticated: authenticated ?? this.authenticated,
    );
  }
}

class AppController extends Notifier<AppCtrlState> {
  @override
  AppCtrlState build() => const AppCtrlState();

  Future<void> init() async {
    final router = GoRouter.of(AppNavigator.context);
    router.go(AppRoutes.home);
  }
}

final appCtrl = NotifierProvider<AppController, AppCtrlState>(AppController.new);
