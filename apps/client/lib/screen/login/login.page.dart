import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nightout/layout/content.layout.dart';
import 'package:nightout/router/app.router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ContentLayout(
      title: 'เข้าสู่ระบบ',
      bottomAction: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () => context.push(AppRoutes.register),
          child: const Text('ลงทะเบียน'),
        ),
      ),
      child: const SizedBox.shrink(),
    );
  }
}
