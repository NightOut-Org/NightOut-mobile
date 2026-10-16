import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nightout/app.dart';
import 'package:nightout_core/nightout_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
