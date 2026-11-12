import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/active_alerts/active_alerts_view_model.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/active_alerts/components/alert_item.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/active_alerts/components/critical_alert_card.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/active_alerts/components/escalation_notice.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/screen_states.dart';

/// "Activas" tab of the Alerts screen. The screen around it owns the view model.
class ActiveAlertsView extends StatelessWidget {
  final ActiveAlertsViewModel viewModel;
  final ValueChanged<String> onAlertTap;
  final VoidCallback onCall;
  final VoidCallback onManageContacts;

  const new({
    super.key,
    required this.viewModel,
    required this.onAlertTap,
    required this.onCall,
    required this.onManageContacts,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        final state = viewModel.state;
        final hasAlerts = state.activeCount > 0;

        if (state.isLoading && !hasAlerts) return const LoadingView();
        if (state.errorMessage != null && !hasAlerts) {
          return ErrorRetryView(message: state.errorMessage!, onRetry: viewModel.loadAlerts);
        }

        return RefreshIndicator(
          onRefresh: viewModel.refresh,
          child: !hasAlerts
              ? _AllGood(careRecipientFirstName: state.careRecipientFirstName)
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: [
                    if (state.featuredAlert case final featured?) ...[
                      CriticalAlertCard(
                        key: ValueKey(featured.alert.id),
                        item: featured,
                        careRecipientFirstName: state.careRecipientFirstName,
                        now: state.now,
                        escalationSecondsLeft: state.escalationSecondsLeft,
                        isAcknowledging: state.acknowledgingAlertId == featured.alert.id,
                        onTap: () => onAlertTap(featured.alert.id),
                        onAcknowledge: () => viewModel.acknowledge(featured.alert.id),
                        onCall: onCall,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (state.otherAlerts.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 12),
                        child: Text(
                          state.featuredAlert != null ? 'Otras alertas activas' : 'Alertas activas',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      for (final item in state.otherAlerts) ...[
                        AlertItem(
                          key: ValueKey(item.alert.id),
                          item: item,
                          careRecipientFirstName: state.careRecipientFirstName,
                          now: state.now,
                          onTap: () => onAlertTap(item.alert.id),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                    if (state.escalationEnabled)
                      EscalationNotice(ackTimeoutSec: state.ackTimeoutSec, onManageContacts: onManageContacts),
                  ],
                ),
        );
      },
    );
  }
}

/// No active alerts: the calm state, with a way to pull for news.
class _AllGood extends StatelessWidget {
  final String careRecipientFirstName;

  const new({required this.careRecipientFirstName});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    // A scrollable, so pull to refresh also works when there is nothing to list
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 80),
        Center(
          child: CircleAvatar(
            radius: 32,
            backgroundColor: scheme.primaryContainer,
            child: Icon(Icons.check, size: 30, color: scheme.primary),
          ),
        ),
        const SizedBox(height: 16),
        Text('$careRecipientFirstName está bien', textAlign: TextAlign.center, style: text.titleLarge),
        const SizedBox(height: 4),
        Text(
          'No hay alertas activas. Te avisaremos al instante si algo cambia.',
          textAlign: TextAlign.center,
          style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
