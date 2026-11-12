import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/service_locator.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/routines/routines_page.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/routines/routines_view_model.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_settings/alert_settings_page.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_settings/alert_settings_view_model.dart';

/// App shell behind the sign-in: one tab per bounded context. Home, Health and Location join as they are built.
class MainPage extends StatefulWidget {
  const new({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Created once: each page owns its view model and disposes it, so the tabs must not be rebuilt on every switch
  late final List<Widget> _pages = [
    RoutinesPage(viewModel: getIt<RoutinesViewModel>()),
    AlertSettingsPage(viewModel: getIt<AlertSettingsViewModel>()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Keeps every tab alive, with its scroll position and loaded data
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Rutinas',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alertas',
          ),
        ],
      ),
    );
  }
}
