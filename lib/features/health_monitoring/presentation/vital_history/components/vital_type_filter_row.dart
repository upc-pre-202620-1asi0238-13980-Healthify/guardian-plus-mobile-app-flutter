import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_type.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/common/vital_filter.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/common/vital_signs_labels.dart';

/// "Ritmo · Presión · SpO₂ · Temp · Respir": which vital sign the chart shows. One "Presión" chip covers both
/// halves of the blood pressure, the chart follows the systolic value. Only the types the filter keeps are offered.
class VitalTypeFilterRow extends StatelessWidget {
  final List<VitalSignType> types;
  final VitalSignType selected;
  final ValueChanged<VitalSignType> onSelect;

  const new({super.key, this.types = displayedVitalTypes, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(GuardianRadius.medium);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (index, type) in types.indexed) ...[
            if (index > 0) const SizedBox(width: 8),
            Material(
              color: type == selected ? colors.primary : colors.primaryContainer,
              borderRadius: radius,
              child: InkWell(
                onTap: () => onSelect(type),
                borderRadius: radius,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    type.shortLabel,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: type == selected ? colors.onPrimary : colors.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
