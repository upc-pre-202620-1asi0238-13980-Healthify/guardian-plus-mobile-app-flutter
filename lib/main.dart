import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/service_locator.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/core/session/demo_care_context.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_settings/alert_settings_page.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_settings/alert_settings_view_model.dart';

void main() {
  setupDependencies();
  // Until the sign-in exists in this app, the screens work with the demo family of the platform
  getIt<CareContextStore>().save(demoCareContext);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guardian+',
      theme: GuardianTheme.light(),
      debugShowCheckedModeBanner: false,
      // Temporary entry point: the app shell (home and tabs) will open this screen from the Alerts tab
      home: AlertSettingsPage(viewModel: getIt<AlertSettingsViewModel>()),
    );
  }
}
