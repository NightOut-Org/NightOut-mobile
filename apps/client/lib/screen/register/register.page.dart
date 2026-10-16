import 'package:flutter/material.dart';
import 'package:nightout/layout/content.layout.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContentLayout(
      title: 'ลงทะเบียน',
      child: SizedBox.shrink(),
    );
  }
}
