import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nightout_core/nightout_core.dart';
import 'package:nightout/config.dart';
import 'package:nightout/extensions/context.extension.dart';
import 'package:nightout/models/app/splash.model.dart';
import 'package:nightout/modules/controller/app.ctrl.dart';
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
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(_minimumDisplay);
    if (!mounted) return;
    await ref.read(appCtrl.notifier).init();
  }

  @override
  Widget build(BuildContext context) {
    final error = ref.watch(appCtrl.select((s) => s.error));
    final colors = context.colors;

    return Scaffold(
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
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [colors.titleFrom, colors.titleTo],
                  ).createShader(bounds),
                  child: Text(
                    Config.appname,
                    style: NightOutText.display(
                      context.textTheme.headlineMedium,
                      colors,
                    ).copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 32),
                if (error.isEmpty)
                  const LoadWidget()
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      error,
                      textAlign: TextAlign.center,
                      style: NightOutText.sans(
                        fontSize: 14,
                        color: colors.muted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
