import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';

/// "Estás cuidando a Elena Rojas · Cambiar": who the numbers below belong to.
class CareRecipientCard extends StatelessWidget {
  final String name;
  final bool hasLiveSignal;
  final VoidCallback onChangeTap;

  const new({super.key, required this.name, required this.hasLiveSignal, required this.onChangeTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(GuardianRadius.medium);

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: radius, side: BorderSide(color: colors.outline)),
      child: InkWell(
        onTap: onChangeTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: radius),
                    child: Text(
                      name.isEmpty ? '' : name.substring(0, 1).toUpperCase(),
                      style: text.titleMedium?.copyWith(color: colors.primary),
                    ),
                  ),
                  // Green dot while the wearable is streaming
                  if (hasLiveSignal)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.surface, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estás cuidando a', style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
                    Text(name, style: text.titleSmall?.copyWith(color: colors.onSurface)),
                  ],
                ),
              ),
              Text('Cambiar', style: text.labelLarge?.copyWith(color: colors.primary)),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 16, color: colors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
