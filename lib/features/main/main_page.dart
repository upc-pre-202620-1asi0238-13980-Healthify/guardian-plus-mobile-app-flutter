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

/// Tabs of the bottom bar, in the order of the team prototype. Location joins once it is built.
enum _Tab { home, health, alerts, routines }

/// App shell behind the sign-in: one tab per bounded context, starting on "Inicio".
class MainPage extends StatefulWidget {
  const new({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  _Tab _selected = _Tab.home;

  void _open(_Tab tab) => setState(() => _selected = tab);

  // Created once: each page owns its view model and disposes it, so the tabs must not be rebuilt on every switch
  late final List<Widget> _pages = [
    HomePage(
      viewModel: getIt<LiveVitalsViewModel>(),
      onSeeVitalsTap: () => _open(_Tab.health),
      onAlertsTap: () => _open(_Tab.alerts),
    ),
    HealthPage(
      liveVitalsViewModel: getIt<LiveVitalsViewModel>(),
      vitalHistoryViewModel: getIt<VitalHistoryViewModel>(),
    ),
    AlertSettingsPage(viewModel: getIt<AlertSettingsViewModel>()),
    RoutinesPage(viewModel: getIt<RoutinesViewModel>()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Keeps every tab alive, with its scroll position and loaded data
      body: IndexedStack(index: _selected.index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selected.index,
        onDestinationSelected: (index) => _open(_Tab.values[index]),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(
            icon: Icon(Icons.monitor_heart_outlined),
            selectedIcon: Icon(Icons.monitor_heart),
            label: 'Salud',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alertas',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Rutinas',
          ),
        ],
      ),
    );
  }
}
