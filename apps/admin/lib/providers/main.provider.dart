import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainState {
  const MainState({this.locale = const Locale('th')});

  final Locale locale;

  MainState copyWith({Locale? locale}) {
    return MainState(locale: locale ?? this.locale);
  }
}

class MainNotifier extends Notifier<MainState> {
  @override
  MainState build() => const MainState();

  void setLocale(Locale locale) {
    state = state.copyWith(locale: locale);
  }
}

final mainProvider = NotifierProvider<MainNotifier, MainState>(MainNotifier.new);
