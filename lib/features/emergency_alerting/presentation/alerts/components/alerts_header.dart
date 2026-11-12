import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';

/// Top bar of the Alerts section: avatar of the signed-in member, title, active alert count and settings.
class AlertsHeader extends StatelessWidget {
  final String userInitials;
  final String careRecipientName;
  final int activeCount;
  final VoidCallback onSettings;

  const new({
    super.key,
    required this.userInitials,
    required this.careRecipientName,
    required this.activeCount,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Material(
      color: scheme.surface,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: scheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(GuardianRadius.medium),
                    ),
                    child: Text(userInitials, style: text.titleMedium?.copyWith(color: scheme.primary)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(careRecipientName, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                        Text('Alertas', style: text.titleLarge),
                      ],
                    ),
                  ),
                  if (activeCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: scheme.errorContainer,
                        borderRadius: BorderRadius.circular(GuardianRadius.large),
                      ),
                      child: Text(
                        activeCount == 1 ? '1 activa' : '$activeCount activas',
                        style: text.labelMedium?.copyWith(color: scheme.onErrorContainer),
                      ),
                    ),
                  const SizedBox(width: 8),
                  // "Configurar" of the report: emergency contacts and alert settings
                  IconButton.outlined(
                    onPressed: onSettings,
                    tooltip: 'Configurar alertas',
                    icon: const Icon(Icons.settings_outlined, size: 20),
                    style: IconButton.styleFrom(
                      side: BorderSide(color: scheme.outline),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GuardianRadius.medium)),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
