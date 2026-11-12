import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/alert_detail/alert_detail_state.dart';

/// Which buttons the current state allows; every flag maps to a command the platform accepts right now.
class AvailableActions {
  final bool canAcknowledge;
  final bool canClaim;
  final bool canComplete;
  final bool canStabilize;
  final bool canClose;
  final bool canCall;
  final bool canCallEmergency;

  const new({
    this.canAcknowledge = false,
    this.canClaim = false,
    this.canComplete = false,
    this.canStabilize = false,
    this.canClose = false,
    this.canCall = false,
    this.canCallEmergency = false,
  });
}

class AlertDetailActions extends StatelessWidget {
  final AvailableActions actions;
  final AlertDetailAction? runningAction;
  final String careRecipientFirstName;
  final VoidCallback onAcknowledge;
  final VoidCallback onClaim;
  final VoidCallback onComplete;
  final VoidCallback onStabilize;
  final VoidCallback onClose;
  final VoidCallback onCall;
  final VoidCallback onCallEmergency;

  const new({
    super.key,
    required this.actions,
    required this.runningAction,
    required this.careRecipientFirstName,
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
    final scheme = Theme.of(context).colorScheme;
    final busy = runningAction != null;

    Widget primary(String label, IconData icon, AlertDetailAction action, VoidCallback onPressed) => FilledButton.icon(
      onPressed: busy ? null : onPressed,
      icon: _icon(icon, running: runningAction == action, color: scheme.onPrimary),
      label: Text(label, maxLines: 1),
    );

    Widget secondary(String label, IconData icon, VoidCallback onPressed, {AlertDetailAction? action}) =>
        OutlinedButton.icon(
          onPressed: action != null && busy ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            foregroundColor: scheme.primary,
            side: BorderSide(color: scheme.primary),
          ),
          icon: _icon(icon, running: action != null && runningAction == action, color: scheme.primary),
          label: Text(label, maxLines: 1),
        );

    final buttons = [
      if (actions.canAcknowledge)
        primary('Reconocer alerta', Icons.check, AlertDetailAction.acknowledge, onAcknowledge),
      if (actions.canComplete) primary('Llegué', Icons.location_on_outlined, AlertDetailAction.complete, onComplete),
      if (actions.canClose && !actions.canStabilize)
        primary('Cerrar incidente', Icons.check, AlertDetailAction.close, onClose),
      if (actions.canClaim)
        secondary('Voy en camino', Icons.location_on_outlined, onClaim, action: AlertDetailAction.claim),
      if (actions.canStabilize) ...[
        secondary(
          'Marcar estabilizado',
          Icons.monitor_heart_outlined,
          onStabilize,
          action: AlertDetailAction.stabilize,
        ),
        secondary('Cerrar incidente', Icons.check, onClose, action: AlertDetailAction.close),
      ],
      if (actions.canCall) secondary('Llamar a $careRecipientFirstName', Icons.phone_outlined, onCall),
      if (actions.canCallEmergency)
        FilledButton.icon(
          onPressed: onCallEmergency,
          style: FilledButton.styleFrom(
            backgroundColor: scheme.errorContainer,
            foregroundColor: scheme.onErrorContainer,
            side: BorderSide(color: scheme.error.withAlpha(102)),
          ),
          icon: const Icon(Icons.sos, size: 18),
          label: const Text('Llamar a emergencias (SAMU 106)', maxLines: 1),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, button) in buttons.indexed) ...[if (index > 0) const SizedBox(height: 10), button],
      ],
    );
  }

  static Widget _icon(IconData icon, {required bool running, required Color color}) => running
      ? SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: color))
      : Icon(icon, size: 18);
}
