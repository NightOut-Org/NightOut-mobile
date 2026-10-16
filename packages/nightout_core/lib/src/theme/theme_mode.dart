import 'package:flutter/material.dart';

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
