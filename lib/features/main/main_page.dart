import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/service_locator.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/routines/routines_page.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/routines/routines_view_model.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_settings/alert_settings_page.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_settings/alert_settings_view_model.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/health/health_page.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/home/home_page.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/live_vitals/live_vitals_view_model.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/vital_history/vital_history_view_model.dart';
import 'package:guardian_plus_app/features/main/guardian_bottom_bar.dart';
import 'package:guardian_plus_app/features/main/placeholder_page.dart';
import 'package:guardian_plus_app/features/main/top_level_destination.dart';

/// App shell behind the sign-in: one tab per bounded context, starting on "Inicio". The pages follow the
/// order of [TopLevelDestination].
class MainPage extends StatefulWidget {
  const new({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  TopLevelDestination _selected = TopLevelDestination.home;

  void _open(TopLevelDestination tab) => setState(() => _selected = tab);

  // Created once: each page owns its view model and disposes it, so the tabs must not be rebuilt on every switch
  late final List<Widget> _pages = [
    HomePage(
      viewModel: getIt<LiveVitalsViewModel>(),
      onSeeVitalsTap: () => _open(TopLevelDestination.health),
      onAlertsTap: () => _open(TopLevelDestination.alerts),
    ),
    HealthPage(
      liveVitalsViewModel: getIt<LiveVitalsViewModel>(),
      vitalHistoryViewModel: getIt<VitalHistoryViewModel>(),
    ),
    AlertSettingsPage(viewModel: getIt<AlertSettingsViewModel>()),
    RoutinesPage(viewModel: getIt<RoutinesViewModel>()),
    // Mobility & Geofencing is not built in this app yet
    PlaceholderPage(title: TopLevelDestination.location.label),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Keeps every tab alive, with its scroll position and loaded data
      body: IndexedStack(index: _selected.index, children: _pages),
      bottomNavigationBar: GuardianBottomBar(selected: _selected, onDestinationTap: _open),
    );
  }
}
