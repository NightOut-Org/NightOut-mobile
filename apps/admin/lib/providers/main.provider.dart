import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nightout_core/nightout_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

final initialThemeModeProvider = Provider<NightOutThemeMode>((ref) => NightOutThemeMode.dark);

class MainState {
  const MainState({
    this.locale = const Locale('th'),
    this.themeMode = NightOutThemeMode.dark,
  });

  final Locale locale;
  final NightOutThemeMode themeMode;

  MainState copyWith({
    Locale? locale,
    NightOutThemeMode? themeMode,
  }) {
    return MainState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class MainNotifier extends Notifier<MainState> {
  @override
  MainState build() {
    return MainState(themeMode: ref.watch(initialThemeModeProvider));
  }

  void setLocale(Locale locale) {
    state = state.copyWith(locale: locale);
  }

  Future<void> setThemeMode(NightOutThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(nightOutThemeStorageKey, mode.storageValue);
  }
}

final mainProvider = NotifierProvider<MainNotifier, MainState>(MainNotifier.new);
