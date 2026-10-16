import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nightout_core/nightout_core.dart';
import 'package:nightout/l10n/app_localizations.dart';
import 'package:nightout/l10n/lang.dart';
import 'package:nightout/library/loading.dart';
import 'package:nightout/providers/main.provider.dart';
import 'package:nightout/router/app.router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(mainProvider.select((s) => s.locale));
    final themeMode = ref.watch(nightOutThemeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: Lang.list.map((e) => Locale(e.value)).toList(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: nightOutTheme(Brightness.light),
      darkTheme: nightOutTheme(Brightness.dark),
      themeMode: themeMode.material,
      themeAnimationDuration: context.themeFadeDuration,
      themeAnimationCurve: NightOutMotion.easeOut,
      builder: Loading.init,
      routerConfig: router,
    );
  }
}
