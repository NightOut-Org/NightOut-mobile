import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nightout_core/nightout_core.dart';
import 'package:nightoutadmin/config.dart';
import 'package:nightoutadmin/library/loading.dart';
import 'package:nightoutadmin/providers/main.provider.dart';
import 'package:nightoutadmin/router/app.router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(mainProvider.select((state) => state.locale));
    final themeMode = ref.watch(mainProvider.select((state) => state.themeMode));

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: Config.appName,
      locale: locale,
      supportedLocales: const [Locale('th'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: nightOutTheme(Brightness.light),
      darkTheme: nightOutTheme(Brightness.dark),
      themeMode: themeMode.material,
      themeAnimationDuration: NightOutMotion.themeFade,
      themeAnimationCurve: NightOutMotion.easeOut,
      builder: Loading.init,
      routerConfig: router,
    );
  }
}
