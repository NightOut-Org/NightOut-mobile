import 'package:flutter/material.dart';
import 'package:nightout_core/nightout_core.dart';
import 'package:nightoutadmin/extensions/context.extension.dart';
import 'package:nightoutadmin/layout/content.layout.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ContentLayout(
      title: 'NightOut Admin',
      actions: [
        const NightOutThemeModeMenu(),
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
