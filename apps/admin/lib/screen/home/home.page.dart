import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nightout_core/nightout_core.dart';
import 'package:nightoutadmin/extensions/context.extension.dart';
import 'package:nightoutadmin/layout/content.layout.dart';
import 'package:nightoutadmin/providers/main.provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final themeMode = ref.watch(mainProvider.select((state) => state.themeMode));

    return ContentLayout(
      title: 'NightOut Admin',
      actions: [
        PopupMenuButton<NightOutThemeMode>(
          tooltip: 'ธีม',
          initialValue: themeMode,
          color: colors.card,
          onSelected: (mode) => ref.read(mainProvider.notifier).setThemeMode(mode),
          icon: PhosphorIcon(
            switch (themeMode) {
              NightOutThemeMode.dark => PhosphorIconsFill.moon,
              NightOutThemeMode.light => PhosphorIconsFill.sun,
              NightOutThemeMode.system => PhosphorIconsFill.desktop,
            },
            color: colors.goldText,
          ),
          itemBuilder: (context) {
            return [
              for (final mode in NightOutThemeMode.values)
                PopupMenuItem(value: mode, child: Text(mode.label)),
            ];
          },
        ),
      ],
      child: ListView(
        children: [
          Text('ADMIN', style: NightOutText.eyebrow(colors)),
          const SizedBox(height: 8),
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [colors.titleFrom, colors.titleTo],
              ).createShader(bounds);
            },
            child: Text(
              'NightOut',
              style: NightOutText.display(
                context.textTheme.headlineMedium,
                colors,
              ).copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'โครงแอดมิน พร้อมธีม Midnight Gold',
            style: NightOutText.sans(fontSize: 15, color: colors.muted),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'พื้น การ์ด และตัวอักษรอ่านจากธีมที่เลือกไว้ ค่าที่เก็บในเครื่องคือ $nightOutThemeStorageKey',
                style: NightOutText.sans(fontSize: 15, color: colors.text),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
