import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nightout_core/nightout_core.dart';
import 'package:nightout/config.dart';
import 'package:nightout/models/app/splash.model.dart';
import 'package:nightout/modules/controller/auth.ctrl.dart';
import 'package:nightout/router/app.router.dart';
import 'package:nightout/widgets/splash/animation.design.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends ConsumerState<SplashScreen> {
  static const _minimumDisplay = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();
    // restore() can change provider state at once, which is not allowed while
    // the tree is building.
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final auth = ref.read(customerAuthProvider.notifier);
    try {
      await Future.wait([Future<void>.delayed(_minimumDisplay), auth.restore()]);
    } finally {
      // Leave the splash even when restore() throws something unexpected.
      if (mounted) {
        final signedIn = ref.read(customerAuthProvider) is CustomerSignedIn;
        context.go(signedIn ? AppRoutes.home : AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // No AppBar here, so set the status bar from the theme ourselves.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).appBarTheme.systemOverlayStyle!,
      child: Scaffold(
        backgroundColor: colors.background,
        body: Stack(
          children: [
            TFadeInAnimation(
              durationInMs: 1200,
              animationPosition: TAnimationPosition(
                topBefore: 0,
                topAfter: 0,
                leftBefore: 0,
                leftAfter: 0,
                rightBefore: 0,
                rightAfter: 0,
                bottomBefore: 50,
                bottomAfter: 0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GradientTitle(Config.appname),
                  const SizedBox(height: 32),
                  const LoadWidget(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
