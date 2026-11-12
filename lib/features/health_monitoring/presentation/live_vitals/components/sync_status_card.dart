import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/emergency_alerting/presentation/common/status_chip.dart';

/// "Sincronización activa": whether the last refresh reached the platform.
class SyncStatusCard extends StatelessWidget {
  final bool synced;

  const new({super.key, required this.synced});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(GuardianRadius.large),
        border: Border.all(color: colors.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sincronización activa', style: text.titleSmall?.copyWith(color: colors.onSurface)),
                  const SizedBox(height: 2),
                  Text(
                    'Los datos sin conexión se enviarán automáticamente',
                    style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          StatusChip(
            text: synced ? 'Sincronizado' : 'Reintentando',
            container: synced ? GuardianColors.neutralMuted : GuardianColors.noticeContainer,
            content: synced ? colors.onSurfaceVariant : GuardianColors.onNoticeContainer,
          ),
        ],
      ),
    );
  }
}
