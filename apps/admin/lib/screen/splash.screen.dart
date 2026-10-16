import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:nightout_core/nightout_core.dart';
import 'package:nightoutadmin/extensions/context.extension.dart';
import 'package:nightoutadmin/router/app.router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(seconds: 2), () {
      if (!mounted) return;
      context.go(AppRoutes.home);
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
              ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: [colors.titleFrom, colors.titleTo],
                  ).createShader(bounds);
                },
                child: Text(
                  'NightOut',
                  style: NightOutText.display(
                    context.textTheme.headlineMedium,
                    colors,
                  ).copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: 32),
              const LoadWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
