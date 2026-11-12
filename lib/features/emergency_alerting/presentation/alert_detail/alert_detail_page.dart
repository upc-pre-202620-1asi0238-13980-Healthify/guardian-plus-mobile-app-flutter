import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/service_locator.dart';
import 'package:guardian_plus_app/core/session/care_context_store.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_source_type.dart';
import 'package:guardian_plus_app/features/emergency_alerting/domain/alert_status.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_detail/alert_detail_state.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_detail/alert_detail_view_model.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_detail/components/alert_detail_actions.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_detail/components/alert_hero_card.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_detail/components/escalation_card.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_detail/components/incident_summary_card.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_detail/components/incident_timeline.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_detail/components/notes_dialog.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/alert_colors.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/alert_labels.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/detail_top_bar.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/dialer.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/screen_states.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/status_chip.dart';

class AlertDetailPage extends StatefulWidget {
  final AlertDetailViewModel viewModel;

  const new({super.key, required this.viewModel});

  @override
  State<AlertDetailPage> createState() => _AlertDetailPageState();
}

class _AlertDetailPageState extends State<AlertDetailPage> {
  late final AlertDetailViewModel _viewModel = widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_showActionError);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_showActionError);
    // The page owns its view model: every visit starts with a fresh one (registerFactoryParam)
    _viewModel.dispose();
    super.dispose();
  }

  // A rejected command (e.g. someone else already acknowledged) is reported once
  void _showActionError() {
    final message = _viewModel.state.actionErrorMessage;
    if (message == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    _viewModel.onActionErrorShown();
  }

  Future<void> _confirmStabilize() async {
    final notes = await showDialog<String>(
      context: context,
      builder: (context) => NotesDialog(
        title: 'Marcar como estabilizado',
        message:
            '${_viewModel.state.careRecipientFirstName} ya no está en peligro. El incidente seguirá abierto hasta '
            'que lo cierres.',
        confirmLabel: 'Marcar estabilizado',
      ),
    );
    if (notes != null) _viewModel.stabilize(notes);
  }

  Future<void> _confirmClose() async {
    final notes = await showDialog<String>(
      context: context,
      builder: (context) => const NotesDialog(
        title: 'Cerrar incidente',
        message: 'La alerta quedará resuelta y pasará al historial.',
        confirmLabel: 'Cerrar incidente',
      ),
    );
    if (notes != null) _viewModel.close(notes);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        final state = _viewModel.state;
        final alert = state.alert;
        return Scaffold(
          appBar: DetailTopBar(
            title: alert?.sourceType == AlertSourceType.sosTriggered ? 'Alerta SOS' : 'Detalle de alerta',
            subtitle: state.careRecipientName,
            onBackPressed: Navigator.canPop(context) ? () => Navigator.pop(context) : null,
            trailing: _statusChip(context, state),
          ),
          body: switch (alert) {
            null when state.errorMessage != null => ErrorRetryView(
              message: state.errorMessage!,
              onRetry: _viewModel.load,
            ),
            null => const LoadingView(),
            _ => _DetailBody(
              state: state,
              alert: alert,
              onAcknowledge: _viewModel.acknowledge,
              onClaim: _viewModel.claimResponse,
              onComplete: _viewModel.completeResponse,
              onStabilize: _confirmStabilize,
              onClose: _confirmClose,
              onCall: () => callCareRecipient(context, getIt<CareContextStore>().require()),
              onCallEmergency: () => dial(context, emergencyServicesNumber),
            ),
          },
        );
      },
    );
  }

  /// The incident's state once there is one, else the alert's.
  Widget? _statusChip(BuildContext context, AlertDetailState state) {
    final scheme = Theme.of(context).colorScheme;
    final incident = state.incident;
    final alert = state.alert;
    if (incident != null) {
      final colors = incident.status.colors(scheme);
      return StatusChip(text: incident.status.label, container: colors.container, content: colors.content);
    }
    if (alert != null) {
      final colors = alert.status.colors(scheme);
      return StatusChip(text: alert.status.label, container: colors.container, content: colors.content);
    }
    return null;
  }
}

class _DetailBody extends StatelessWidget {
  final AlertDetailState state;
  final Alert alert;
  final VoidCallback onAcknowledge;
  final VoidCallback onClaim;
  final VoidCallback onComplete;
  final VoidCallback onStabilize;
  final VoidCallback onClose;
  final VoidCallback onCall;
  final VoidCallback onCallEmergency;

  const new({
    required this.state,
    required this.alert,
    required this.onAcknowledge,
    required this.onClaim,
    required this.onComplete,
    required this.onStabilize,
    required this.onClose,
    required this.onCall,
    required this.onCallEmergency,
  });

  @override
  Widget build(BuildContext context) {
    final incident = state.incident;
    final calm = state.isCalm;
    final showContacts =
        state.escalationContacts.isNotEmpty &&
        alert.status != AlertStatus.pendingConfirmation &&
        alert.status != AlertStatus.dismissed;
    final actions = AvailableActions(
      canAcknowledge: state.canAcknowledge,
      canClaim: state.canClaim,
      canComplete: state.myActiveResponseId != null,
      canStabilize: state.canStabilize,
      canClose: state.canClose,
      canCall: !state.isFinished,
      canCallEmergency: alert.sourceType == AlertSourceType.sosTriggered && !state.isFinished,
    );

    final sections = [
      AlertHeroCard(
        alert: alert,
        incident: incident,
        calm: calm,
        careRecipientFirstName: state.careRecipientFirstName,
        confirmationSecondsLeft: state.confirmationSecondsLeft,
        now: state.now,
      ),
      if (calm && incident != null)
        IncidentSummaryCard(
          alert: alert,
          incident: incident,
          acknowledgedByName: state.contactName(alert.acknowledgedByUserId),
          careRecipientFirstName: state.careRecipientFirstName,
        ),
      if (showContacts && !calm)
        EscalationCard(
          contacts: state.escalationContacts,
          escalationSecondsLeft: state.escalationSecondsLeft,
          ackTimeoutSec: state.ackTimeoutSec,
          currentRecipientLevel: alert.currentRecipientLevel,
        ),
      IncidentTimeline(
        events: state.timeline,
        sourceType: alert.sourceType,
        careRecipientFirstName: state.careRecipientFirstName,
      ),
      AlertDetailActions(
        actions: actions,
        runningAction: state.runningAction,
        careRecipientFirstName: state.careRecipientFirstName,
        onAcknowledge: onAcknowledge,
        onClaim: onClaim,
        onComplete: onComplete,
        onStabilize: onStabilize,
        onClose: onClose,
        onCall: onCall,
        onCallEmergency: onCallEmergency,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        for (final (index, section) in sections.indexed) ...[if (index > 0) const SizedBox(height: 14), section],
      ],
    );
  }
}
