import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';

/// Green summary of the prototype: one glance tells if the care recipient is fine.
class StatusHeroCard extends StatelessWidget {
  final String careRecipientFirstName;
  final bool allWithinRange;
  final bool hasLiveSignal;
  final String updatedText;
  final bool hasWristband;
  final VoidCallback onLinkWristbandTap;

  const new({
    super.key,
    required this.careRecipientFirstName,
    required this.allWithinRange,
    required this.hasLiveSignal,
    required this.updatedText,
    required this.hasWristband,
    required this.onLinkWristbandTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    // Orange instead of green as soon as one reading leaves its range
    final container = allWithinRange ? colors.primary : colors.tertiary;
    final onContainer = colors.onPrimary;
    final translucent = onContainer.withValues(alpha: 0.12);
    final muted = onContainer.withValues(alpha: 0.8);
    final radius = BorderRadius.circular(GuardianRadius.medium);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: container, borderRadius: BorderRadius.circular(GuardianRadius.large)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasLiveSignal ? 'ESTADO ACTUAL · EN LÍNEA' : 'ESTADO ACTUAL · SIN SEÑAL',
                      style: text.labelMedium?.copyWith(color: muted),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      allWithinRange ? '$careRecipientFirstName está bien' : '$careRecipientFirstName necesita atención',
                      style: text.headlineSmall?.copyWith(color: onContainer),
                    ),
                    Text(
                      allWithinRange
                          ? 'Lecturas estables · Actualizado ${updatedText.toLowerCase()}'
                          : 'Lecturas fuera de rango · Actualizado ${updatedText.toLowerCase()}',
                      style: text.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: translucent, borderRadius: radius),
                child: Icon(Icons.verified_user_outlined, size: 24, color: onContainer),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Without a wristband the chip is where it gets linked
          Material(
            color: translucent,
            borderRadius: radius,
            child: InkWell(
              onTap: hasWristband ? null : onLinkWristbandTap,
              borderRadius: radius,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.watch_outlined, size: 16, color: onContainer),
                    const SizedBox(width: 8),
                    // Battery level is not reported by the platform, so the prototype's "68 %" is left out
                    Expanded(
                      child: Text(
                        hasWristband ? 'Pulsera conectada' : 'Sin pulsera vinculada',
                        style: text.bodySmall?.copyWith(color: onContainer),
                      ),
                    ),
                    if (!hasWristband) Text('Vincular', style: text.labelLarge?.copyWith(color: onContainer)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
