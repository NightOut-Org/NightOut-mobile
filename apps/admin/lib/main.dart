import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nightoutadmin/app.dart';
import 'package:nightout_core/nightout_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initNightOutSupabase();
  final themeMode = await loadNightOutThemeMode();

  runApp(
    ProviderScope(
      overrides: [
        nightOutInitialThemeModeProvider.overrideWithValue(themeMode),
      ],
      child: const App(),
    ),
  );
}
