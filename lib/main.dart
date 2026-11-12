import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/service_locator.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/core/session/demo_care_context.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/auth/presentation/login_page.dart';
import 'package:guardian_plus_app/features/auth/presentation/login_viewmodel.dart';

void main() {
  setupDependencies();
  // Until the sign-in talks to IAM, the screens behind it work with the demo family of the platform
  getIt<CareContextStore>().save(demoCareContext);
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
