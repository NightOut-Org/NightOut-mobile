import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nightout/config.dart';
import 'package:nightout/modules/controller/auth.ctrl.dart';
import 'package:nightout_core/nightout_core.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final auth = ref.watch(customerAuthProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(Config.appname),
        actions: const [NightOutThemeModeMenu()],
      ),
      body: switch (auth) {
        CustomerSignedIn(:final profile, :final email) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(profile.displayName, style: NightOutText.cardTitle(colors)),
              const SizedBox(height: 4),
              Text(
                profile.roleLabel,
                style: NightOutText.sans(fontSize: 13, color: colors.goldText),
              ),
              const SizedBox(height: 4),
              Text(email, style: NightOutText.sans(fontSize: 13, color: colors.muted)),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => ref.read(customerAuthProvider.notifier).signOut(),
                child: const Text('ออกจากระบบ'),
              ),
            ],
          ),
        ),
        // The router leaves this page as soon as the user is signed out.
        _ => const SizedBox.shrink(),
      },
    );
  }
}
