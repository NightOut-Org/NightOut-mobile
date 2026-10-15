import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nightout/config.dart';
import 'package:nightout/models/app/splash.model.dart';
import 'package:nightout/modules/controller/app.ctrl.dart';
import 'package:nightout/style/app.color.dart';
import 'package:nightout/style/app.theme.dart';
import 'package:nightout/widgets/app/load.widget.dart';
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

    return Scaffold(
      backgroundColor: AppColor.white,
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
                Text(
                  Config.appname,
                  style: AppTextStyle.semiBold(AppTextStyle.heading24).copyWith(
                    color: AppColor.primary,
                  ),
                ),
                const SizedBox(height: 32),
                if (error.isEmpty)
                  const LoadWidget(colors: [AppColor.primary])
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      error,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.body14.copyWith(
                        color: AppColor.textSecondary,
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
