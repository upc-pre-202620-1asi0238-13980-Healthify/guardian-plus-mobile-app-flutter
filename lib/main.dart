import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/service_locator.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/auth/presentation/login_page.dart';
import 'package:guardian_plus_app/features/auth/presentation/login_viewmodel.dart';

void main() {
  setupDependencies();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardian+',
      debugShowCheckedModeBanner: false,
      theme: GuardianTheme.light(),
      home: LoginPage(viewModel: LoginViewmodel()),
    );
  }
}
