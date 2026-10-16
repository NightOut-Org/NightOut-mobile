import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nightout_core/nightout_core.dart';
import 'package:nightoutadmin/app.router.dart';
import 'package:nightoutadmin/modules/controller/auth.ctrl.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;
      final signedIn = await ref.read(authCtrl.notifier).restore();
      if (!mounted) return;
      context.go(signedIn ? AppRoutes.home : AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // No AppBar here, so set the status bar from the theme ourselves.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).appBarTheme.systemOverlayStyle!,
      child: Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const GradientTitle('NightOut'),
              const SizedBox(height: 32),
              const LoadWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
