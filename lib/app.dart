import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nightout/l10n/app_localizations.dart';
import 'package:nightout/l10n/lang.dart';
import 'package:nightout/library/loading.dart';
import 'package:nightout/providers/main.provider.dart';
import 'package:nightout/router/app.router.dart';
import 'package:nightout/style/app.theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(mainProvider.select((s) => s.locale));

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
      theme: AppTheme.theme(context),
      builder: Loading.init,
      routerConfig: router,
    );
  }
}
