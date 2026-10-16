import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nightoutadmin/extensions/context.extension.dart';
import 'package:nightoutadmin/models/admin_dashboard.dart';
import 'package:nightoutadmin/modules/controller/auth.ctrl.dart';
import 'package:nightoutadmin/providers/api.provider.dart';
import 'package:nightoutadmin/providers/dashboard.provider.dart';
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
    // One frame of a signed-out state can render before the router redirects to login.
    final auth = switch (ref.watch(authCtrl)) {
      final AdminSignedIn signedIn => signedIn,
      _ => null,
    };

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

  String _title(AdminSignedIn? auth) {
    final name = auth?.profile.displayName;
    if (name != null && name.isNotEmpty) return name;
    final email = auth?.email;
    if (email != null && email.isNotEmpty) return email;
    return 'Backoffice';
  }

  Widget _body(AdminSignedIn? auth) {
    if (auth == null) return const SizedBox.shrink();
    if (_tab == 4) return _AccountPane(auth: auth);
    if (_tab != 0) {
      return Center(
        child: Text(
          'ยังไม่มีในขั้นนี้',
          style: NightOutText.sans(fontSize: 15, color: context.colors.muted),
        ),
      );
    }
    return const _Dashboard();
  }
}

class _Dashboard extends ConsumerWidget {
  const _Dashboard();

  /// Web `CARDS` in `apps/admin/src/modules/dashboard/page.tsx`, in the same order.
  static final _cards = <(String, int Function(AdminDashboard))>[
    ('การจองวันนี้', (d) => d.bookingsToday),
    ('ปลดโต๊ะวันนี้ (Forfeited)', (d) => d.forfeitedToday),
    ('ร้านรออนุมัติ', (d) => d.barsPending),
    ('สลิปมัดจำรอตรวจ', (d) => d.depositsToVerify),
    ('มัดจำรอโอนให้ร้าน', (d) => d.payoutsPending),
    ('สลิปโปรโมทรอตรวจ', (d) => d.promoSlipsPending),
    ('รีวิวถูกรายงาน', (d) => d.reviewsReported),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final dashboard = ref.watch(dashboardProvider);

    final error = dashboard.error;
    // MFA_REQUIRED already sent the user back to the code step; the redirect follows shortly.
    final reverifying = error is ApiException && error.code == mfaRequiredCode;
    if (dashboard.isLoading || reverifying) return const Center(child: LoadWidget());

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                error is ApiException ? error.message : 'โหลดแดชบอร์ดไม่สำเร็จ',
                textAlign: TextAlign.center,
                style: NightOutText.sans(fontSize: 15, color: colors.text),
              ),
              const SizedBox(height: 16),
              _RetryButton(onPressed: () => ref.invalidate(dashboardProvider)),
            ],
          ),
        ),
      );
    }

    final data = dashboard.value;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        for (final (label, count) in _cards) _DashboardRow(label: label, count: data == null ? 0 : count(data)),
      ],
    );
  }
}

class _DashboardRow extends StatelessWidget {
  const _DashboardRow({required this.label, required this.count});

  final String label;
  final int count;

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
            child: Text(label, style: NightOutText.sans(fontSize: 15, color: colors.text)),
          ),
          Text(
            '$count',
            style: NightOutText.sans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colors.goldText,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountPane extends ConsumerWidget {
  const _AccountPane({required this.auth});

  final AdminSignedIn auth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final role = auth.profile.roleLabel;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      children: [
        Text(_name(auth), style: NightOutText.cardTitle(colors)),
        if (auth.email.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(auth.email, style: NightOutText.sans(fontSize: 14, color: colors.muted)),
        ],
        if (role.isNotEmpty) ...[
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

  String _name(AdminSignedIn auth) {
    final name = auth.profile.displayName;
    return name.isNotEmpty ? name : 'บัญชีผู้ดูแล';
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
