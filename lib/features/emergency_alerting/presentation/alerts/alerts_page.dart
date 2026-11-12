import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/service_locator.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/core/text/initials.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/active_alerts/active_alerts_view.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/active_alerts/active_alerts_view_model.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_history/alert_history_view.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_history/alert_history_view_model.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alerts/components/alerts_header.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alerts/components/alerts_tab_bar.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/dialer.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/navigation/emergency_alerting_navigation.dart';

/// Alerts tab of the bottom bar: shared header and the "Activas · Historial" tabs.
class AlertsPage extends StatefulWidget {
  final ActiveAlertsViewModel activeAlertsViewModel;
  final AlertHistoryViewModel alertHistoryViewModel;

  const new({super.key, required this.activeAlertsViewModel, required this.alertHistoryViewModel});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  late final ActiveAlertsViewModel _activeAlerts = widget.activeAlertsViewModel;
  late final AlertHistoryViewModel _history = widget.alertHistoryViewModel;
  var _selectedTab = AlertsTab.active;

  @override
  void initState() {
    super.initState();
    _activeAlerts.addListener(_onActiveAlertsChanged);
  }

  @override
  void dispose() {
    _activeAlerts.removeListener(_onActiveAlertsChanged);
    // The page owns both view models (registerFactory)
    _activeAlerts.dispose();
    _history.dispose();
    super.dispose();
  }

  void _onActiveAlertsChanged() {
    if (!mounted) return;
    final state = _activeAlerts.state;
    // After "Reconocer" the member goes straight to the incident in attention
    final acknowledged = state.acknowledgedAlertId;
    if (acknowledged != null) {
      _activeAlerts.onAcknowledgedAlertOpened();
      _openAlert(acknowledged);
    }
    // A rejected acknowledgement (e.g. someone else already did it) is reported once
    final message = state.actionErrorMessage;
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      _activeAlerts.onActionErrorShown();
    }
  }

  // Coming back, the alert may have changed state in both lists
  Future<void> _openAlert(String alertId) async {
    await openAlertDetail(context, alertId);
    _activeAlerts.refresh();
    _history.refresh();
  }

  Future<void> _openSettings() async {
    await openAlertSettings(context);
    // The timeout and the escalation switch show in the list
    _activeAlerts.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final careContext = getIt<CareContextStore>().require();
    return Scaffold(
      body: Column(
        children: [
          ListenableBuilder(
            listenable: _activeAlerts,
            builder: (context, child) => AlertsHeader(
              userInitials: initialsOf(careContext.userFullName),
              careRecipientName: careContext.careRecipientName,
              activeCount: _activeAlerts.state.activeCount,
              onSettings: _openSettings,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
            child: AlertsTabBar(selected: _selectedTab, onSelected: (tab) => setState(() => _selectedTab = tab)),
          ),
          Expanded(
            // Both tabs stay alive, with their scroll position and loaded data
            child: IndexedStack(
              index: _selectedTab.index,
              children: [
                ActiveAlertsView(
                  viewModel: _activeAlerts,
                  onAlertTap: _openAlert,
                  onCall: () => callCareRecipient(context, getIt<CareContextStore>().require()),
                  onManageContacts: () => openEmergencyContacts(context),
                ),
                AlertHistoryView(viewModel: _history, onAlertTap: _openAlert),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
