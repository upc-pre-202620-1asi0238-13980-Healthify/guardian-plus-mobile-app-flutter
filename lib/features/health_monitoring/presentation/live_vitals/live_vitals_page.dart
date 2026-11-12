import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_labels.dart';
import 'package:guardian_plus_app/features/health_monitoring/domain/vital_sign_type.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/common/error_state.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/common/live_vitals_state.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/common/vital_filter.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/common/vital_signs_labels.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/live_vitals/components/heart_rate_hero_card.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/live_vitals/components/range_bar.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/live_vitals/components/sync_status_card.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/live_vitals/components/vital_tile.dart';
import 'package:guardian_plus_app/features/health_monitoring/presentation/live_vitals/live_vitals_view_model.dart';

// Enough to show the shape of the last minutes without crowding the card
const _sparklinePoints = 40;

/// "Salud › Ahora": the heart rate up front, then the latest reading of every other vital sign. The Health page
/// owns the view model, so this one only listens to it.
class LiveVitalsPage extends StatelessWidget {
  final LiveVitalsViewModel viewModel;
  final VitalFilter filter;

  const new({super.key, required this.viewModel, this.filter = const VitalFilter()});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        final state = viewModel.state;
        final vitals = state.vitals;
        if (vitals == null && state.isLoading) return const Center(child: CircularProgressIndicator());
        if (vitals == null || vitals.vitalSigns.isEmpty) {
          return ErrorState(
            message: state.errorMessage ?? 'La pulsera aún no envió lecturas',
            onRetry: viewModel.load,
          );
        }

        final shown = displayedVitalTypes
            .where((type) => filter.includes(type) && vitals[type] != null && filter.includesState(state.isWithinRange(type)))
            .toList();
        final tiles = shown.where((type) => type != VitalSignType.hr).toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            if (shown.contains(VitalSignType.hr)) ...[_HeroCard(state: state), const SizedBox(height: 12)],
            // Two per row as in the prototype; equal heights so the range bars line up
            for (var i = 0; i < tiles.length; i += 2) ...[
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _Tile(state: state, type: tiles[i])),
                    const SizedBox(width: 12),
                    Expanded(child: i + 1 < tiles.length ? _Tile(state: state, type: tiles[i + 1]) : const SizedBox()),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (shown.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Ningún signo vital coincide con los filtros',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            SyncStatusCard(synced: state.errorMessage == null),
          ],
        );
      },
    );
  }
}

class _HeroCard extends StatelessWidget {
  final LiveVitalsState state;

  const new({required this.state});

  @override
  Widget build(BuildContext context) {
    const type = VitalSignType.hr;
    final reading = state.vitals![type]!;
    final lastReading = lowercaseFirst(relativeTime(reading.measuredAt, state.now));
    final today = state.todayValues(type);
    final trend = state.trend(type);
    final sparkline = today.length > _sparklinePoints ? today.sublist(today.length - _sparklinePoints) : today;

    return HeartRateHeroCard(
      title: type.title,
      valueText: type.format(reading.value),
      unit: type.displayUnit,
      withinRange: state.isWithinRange(type),
      timeText: formatClockTime(reading.measuredAt),
      caption: trend != null ? '${trend.label} · última lectura $lastReading' : 'Última lectura $lastReading',
      sparkline: sparkline.isEmpty ? [reading.value] : sparkline,
      wristbandText: !state.hasWristband
          ? 'Sin pulsera vinculada'
          : state.hasLiveSignal
          ? 'Pulsera conectada'
          : 'Pulsera sin señal',
      maxMinText: today.isEmpty
          ? null
          : 'Máx ${type.format(today.reduce((a, b) => a > b ? a : b))} · '
                'Mín ${type.format(today.reduce((a, b) => a < b ? a : b))}',
    );
  }
}

class _Tile extends StatelessWidget {
  final LiveVitalsState state;
  final VitalSignType type;

  const new({required this.state, required this.type});

  @override
  Widget build(BuildContext context) {
    final reading = state.vitals?[type];
    final trend = state.trend(type)?.label;
    final time = reading != null ? lowercaseFirst(relativeTime(reading.measuredAt, state.now)) : null;
    final caption = [?trend, ?time].join(' · ');

    return VitalTile(
      title: type.title,
      valueText: type == VitalSignType.bpSys
          ? state.bloodPressureText
          : reading != null
          ? type.format(reading.value)
          : null,
      unit: type.displayUnit,
      withinRange: state.isWithinRange(type),
      // Blood pressure is placed by its systolic half, the one the range bar can show
      marker: reading != null
          ? RangeMarker(value: reading.value, normalMinimum: reading.normalMinimum, normalMaximum: reading.normalMaximum)
          : null,
      caption: caption.isEmpty ? null : caption,
    );
  }
}
