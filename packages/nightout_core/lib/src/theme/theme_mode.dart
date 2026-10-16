import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Same key and values as the web's theme switch.
const nightOutThemeStorageKey = 'nightout-theme';

enum NightOutThemeMode {
  dark('DARK', 'มืด'),
  light('LIGHT', 'สว่าง'),
  system('SYSTEM', 'ตามเครื่อง');

  const NightOutThemeMode(this.storageValue, this.label);

  final String storageValue;
  final String label;

  ThemeMode get material => switch (this) {
    NightOutThemeMode.dark => ThemeMode.dark,
    NightOutThemeMode.light => ThemeMode.light,
    NightOutThemeMode.system => ThemeMode.system,
  };

  static NightOutThemeMode fromStorage(String? value) {
    for (final mode in NightOutThemeMode.values) {
      if (mode.storageValue == value) return mode;
    }
    return NightOutThemeMode.dark;
  }
}

/// Read before `runApp` and pass to [nightOutInitialThemeModeProvider], so a
/// LIGHT user does not see a dark first frame.
Future<NightOutThemeMode> loadNightOutThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  return NightOutThemeMode.fromStorage(prefs.getString(nightOutThemeStorageKey));
}

final nightOutInitialThemeModeProvider = Provider<NightOutThemeMode>(
  (ref) => NightOutThemeMode.dark,
);

final nightOutThemeModeProvider =
    NotifierProvider<NightOutThemeModeNotifier, NightOutThemeMode>(
      NightOutThemeModeNotifier.new,
    );

class NightOutThemeModeNotifier extends Notifier<NightOutThemeMode> {
  @override
  NightOutThemeMode build() => ref.watch(nightOutInitialThemeModeProvider);

  Future<void> set(NightOutThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(nightOutThemeStorageKey, mode.storageValue);
  }
}
