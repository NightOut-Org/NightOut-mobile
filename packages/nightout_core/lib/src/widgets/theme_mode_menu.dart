import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/theme.dart';
import '../theme/theme_mode.dart';

/// App-bar button for DARK / LIGHT / SYSTEM, like the web header's ThemeToggle.
class NightOutThemeModeMenu extends ConsumerWidget {
  const NightOutThemeModeMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final mode = ref.watch(nightOutThemeModeProvider);

    return PopupMenuButton<NightOutThemeMode>(
      tooltip: 'ธีม',
      initialValue: mode,
      color: colors.card,
      onSelected: ref.read(nightOutThemeModeProvider.notifier).set,
      icon: PhosphorIcon(
        switch (mode) {
          NightOutThemeMode.dark => PhosphorIconsFill.moon,
          NightOutThemeMode.light => PhosphorIconsFill.sun,
          NightOutThemeMode.system => PhosphorIconsFill.desktop,
        },
        color: colors.goldText,
      ),
      itemBuilder: (context) => [
        for (final mode in NightOutThemeMode.values)
          PopupMenuItem(value: mode, child: Text(mode.label)),
      ],
    );
  }
}
