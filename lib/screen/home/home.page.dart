import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nightout/config.dart';
import 'package:nightout/router/app.router.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Config.appname),
      ),
      body: Center(
        child: FilledButton(
          onPressed: () => context.push(AppRoutes.login),
          child: const Text('ไปหน้า Login'),
        ),
      ),
    );
  }
}
