import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nightoutadmin/extensions/context.extension.dart';
import 'package:nightoutadmin/models/auth/auth.models.dart';
import 'package:nightoutadmin/modules/controller/auth.ctrl.dart';
import 'package:nightout_core/nightout_core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final auth = ref.watch(authCtrl);

    return Scaffold(
      backgroundColor: colors.background,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.heroVia, colors.background],
            stops: const [0, 0.28],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.maxWidthPadding),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: Row(
                    children: [
                      const NightOutThemeModeMenu(),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _title(auth),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: NightOutText.sans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: colors.text,
                              ),
                            ),
                            Text(
                              'โหมดกลางคืน',
                              style: NightOutText.sans(fontSize: 12, color: colors.goldText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _body(auth)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(icon: PhosphorIcon(PhosphorIconsRegular.house), label: 'หน้าแรก'),
          NavigationDestination(icon: PhosphorIcon(PhosphorIconsRegular.chartBar), label: 'รายงาน'),
          NavigationDestination(icon: PhosphorIcon(PhosphorIconsRegular.storefront), label: 'ร้าน'),
          NavigationDestination(icon: PhosphorIcon(PhosphorIconsRegular.bell), label: 'แจ้งเตือน'),
          NavigationDestination(icon: PhosphorIcon(PhosphorIconsRegular.user), label: 'บัญชี'),
        ],
      ),
    );
  }

  String _title(AuthState auth) {
    final name = auth.profile?.displayName;
    if (name != null && name.isNotEmpty) return name;
    if (auth.email != null && auth.email!.isNotEmpty) return auth.email!;
    return 'Backoffice';
  }

  Widget _body(AuthState auth) {
    if (_tab == 4) return _AccountPane(auth: auth);
    if (_tab != 0) {
      return Center(
        child: Text(
          'ยังไม่มีในขั้นนี้',
          style: NightOutText.sans(fontSize: 15, color: context.colors.muted),
        ),
      );
    }
    return _Dashboard(auth: auth);
  }
}

class _Dashboard extends ConsumerWidget {
  const _Dashboard({required this.auth});

  final AuthState auth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final dashboard = auth.dashboard;

    if (dashboard == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                auth.notice ?? 'โหลดแดชบอร์ดไม่สำเร็จ',
                textAlign: TextAlign.center,
                style: NightOutText.sans(fontSize: 15, color: colors.text),
              ),
              const SizedBox(height: 16),
              _RetryButton(onPressed: () => ref.read(authCtrl.notifier).reloadBackoffice()),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        Text(
          '${dashboard.total}',
          style: NightOutText.display(context.textTheme.headlineMedium, colors).copyWith(
            fontSize: 56,
            color: colors.text,
          ),
        ),
        Text(dashboard.unit, style: NightOutText.sans(fontSize: 14, color: colors.muted)),
        const SizedBox(height: 20),
        if (dashboard.items.isEmpty)
          Text('ยังไม่มีรายการ', style: NightOutText.sans(fontSize: 15, color: colors.muted))
        else
          for (final item in dashboard.items)
            _DashboardRow(item: item),
      ],
    );
  }
}

class _DashboardRow extends StatelessWidget {
  const _DashboardRow({required this.item});

  final DashboardItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(item.label, style: NightOutText.sans(fontSize: 15, color: colors.text)),
          ),
          Text(
            '${item.count}',
            style: NightOutText.sans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colors.goldText,
            ),
          ),
          const SizedBox(width: 8),
          PhosphorIcon(PhosphorIconsRegular.caretRight, size: 16, color: colors.muted),
        ],
      ),
    );
  }
}

class _AccountPane extends ConsumerWidget {
  const _AccountPane({required this.auth});

  final AuthState auth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final role = auth.profile?.roleLabel;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      children: [
        Text(_name(auth), style: NightOutText.cardTitle(colors)),
        if (auth.email != null) ...[
          const SizedBox(height: 6),
          Text(auth.email!, style: NightOutText.sans(fontSize: 14, color: colors.muted)),
        ],
        if (role != null && role.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(role, style: NightOutText.sans(fontSize: 14, color: colors.goldText)),
        ],
        const SizedBox(height: 24),
        SizedBox(
          height: 48,
          child: OutlinedButton(
            onPressed: () => ref.read(authCtrl.notifier).signOut(),
            child: const Text('ออกจากระบบ'),
          ),
        ),
      ],
    );
  }

  String _name(AuthState auth) {
    final name = auth.profile?.displayName;
    if (name != null && name.isNotEmpty) return name;
    return 'บัญชีผู้ดูแล';
  }
}

class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: colors.gold,
        foregroundColor: colors.onGold,
      ),
      child: const Text('ลองอีกครั้ง'),
    );
  }
}
