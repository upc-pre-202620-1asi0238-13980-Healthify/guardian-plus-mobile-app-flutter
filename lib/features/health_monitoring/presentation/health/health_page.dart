import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/common/vital_filter.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/health/components/health_header.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/health/components/health_tab_row.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/health/components/vital_filter_sheet.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/health/components/vital_search_bar.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/live_vitals/live_vitals_page.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/live_vitals/live_vitals_view_model.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/vital_history/vital_history_page.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/vital_history/vital_history_view_model.dart';

/// Health tab of the bottom bar: shared header, the "Ahora · Historial" tabs and the search bar over both.
class HealthPage extends StatefulWidget {
  final LiveVitalsViewModel liveVitalsViewModel;
  final VitalHistoryViewModel vitalHistoryViewModel;

  const new({super.key, required this.liveVitalsViewModel, required this.vitalHistoryViewModel});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  late final LiveVitalsViewModel _liveVitals = widget.liveVitalsViewModel;
  late final VitalHistoryViewModel _history = widget.vitalHistoryViewModel;

  // Pure UI choices, so they live here and not in a view model
  HealthTab _selectedTab = HealthTab.now;
  // The filter is shared by both tabs
  VitalFilter _filter = const VitalFilter();

  @override
  void dispose() {
    // The page owns both view models (registerFactory)
    _liveVitals.dispose();
    _history.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    final applied = await showVitalFilterSheet(context, applied: _filter);
    if (applied == null || !mounted) return;
    setState(() => _filter = applied);
    // The view model decides whether the new filter needs another period from the platform
    _history.applyFilter(applied);
  }

  @override
  Widget build(BuildContext context) {
    final careContext = _liveVitals.careContext;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ListenableBuilder(
              listenable: _liveVitals,
              builder: (context, child) {
                final state = _liveVitals.state;
                return HealthHeader(
                  userInitials: _liveVitals.userInitials,
                  careRecipientName: careContext.careRecipientName,
                  hasLiveSignal: state.hasLiveSignal,
                  allWithinRange: state.allWithinRange,
                  hasReadings: state.vitals?.vitalSigns.isNotEmpty ?? false,
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: HealthTabRow(
                selectedTab: _selectedTab,
                onTabSelected: (tab) => setState(() => _selectedTab = tab),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: VitalSearchBar(filter: _filter, onTap: _openFilters),
            ),
            Expanded(
              child: switch (_selectedTab) {
                HealthTab.now => LiveVitalsPage(viewModel: _liveVitals, filter: _filter),
                HealthTab.history => VitalHistoryPage(viewModel: _history),
              },
            ),
          ],
        ),
      ),
    );
  }
}
