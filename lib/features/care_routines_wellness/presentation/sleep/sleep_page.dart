import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/sleep_classification.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/sleep_cycle_record.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_banner.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_card.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_labels.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_progress_bar.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_screen_states.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_tone.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_top_bar.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/sleep/sleep_state.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/sleep/sleep_view_model.dart';

// Continuity from which a night reads as restful, matching the platform's "few interruptions"
const _goodContinuity = 80;

class SleepPage extends StatefulWidget {
  final SleepViewModel viewModel;

  const new({super.key, required this.viewModel});

  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  late final SleepViewModel _viewModel = widget.viewModel;

  @override
  void dispose() {
    // The page owns its view model: every visit starts with a fresh one (registerFactory)
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        final state = _viewModel.state;
        final lastNight = state.lastNight;
        return Scaffold(
          appBar: RoutineTopBar(
            title: 'Sueño',
            subtitle: 'Descanso nocturno',
            onBackPressed: () => Navigator.pop(context),
            action: lastNight != null ? _ClassificationBadge(classification: lastNight.classification) : null,
          ),
          body: switch (state) {
            SleepState(isLoaded: false, errorMessage: null) => const RoutineLoadingState(),
            SleepState(isLoaded: false) => RoutineErrorState(
              message: state.errorMessage ?? '',
              onRetry: _viewModel.load,
            ),
            _ when lastNight == null => const RoutineEmptyState(
              icon: Icons.bedtime_outlined,
              title: 'Sin registros de sueño',
              message: 'La pulsera registrará la primera noche completa de sueño.',
            ),
            _ => _SleepList(state: state, lastNight: lastNight),
          },
        );
      },
    );
  }
}

class _SleepList extends StatelessWidget {
  final SleepState state;
  final SleepCycleRecord lastNight;

  const new({required this.state, required this.lastNight});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        _LastNightCard(night: lastNight, now: state.now),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _MetricCard(
                  label: 'Continuidad',
                  value: '${lastNight.continuityScore}%',
                  detail: lastNight.continuityScore >= _goodContinuity ? 'Sueño continuo' : 'Con interrupciones',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  label: 'Despertares',
                  value: '${lastNight.interruptionCount}',
                  detail: 'Durante la noche',
                ),
              ),
            ],
          ),
        ),
        if (lastNight.classification == SleepClassification.fragmented) ...[
          const SizedBox(height: 10),
          const RoutineBanner(
            icon: Icons.bedtime_outlined,
            title: 'Sueño fragmentado detectado',
            message: 'Se registraron más de 4 interrupciones. Observa si este patrón continúa.',
            tone: RoutineTone.orange,
          ),
        ],
        const SizedBox(height: 10),
        const RoutineSectionTitle(text: 'Últimos 7 días'),
        const SizedBox(height: 10),
        _SleepHistoryCard(nights: state.nights),
        const SizedBox(height: 10),
        const RoutineInfoLine(
          icon: Icons.watch_outlined,
          text: 'Datos estimados a partir de micromovimientos y frecuencia cardíaca.',
        ),
      ],
    );
  }
}

/// "ANOCHE · 22:48–06:36 · 7 h 24 min" on a violet moon.
class _LastNightCard extends StatelessWidget {
  final SleepCycleRecord night;
  final DateTime now;

  const new({required this.night, required this.now});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final range = '${formatClockTime(night.startTime)}–${formatClockTime(night.endTime)}';
    final label = isSameDay(night.endTime, now)
        ? 'ANOCHE · $range'
        : '${formatDayAndMonth(night.endTime).toUpperCase()} · $range';

    return RoutineCard(
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: RoutineColors.restContainer,
                borderRadius: BorderRadius.circular(GuardianRadius.medium),
              ),
              child: const Icon(Icons.bedtime_outlined, size: 26, color: RoutineColors.onRestContainer),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: dataLabelStyle.copyWith(color: colors.onSurfaceVariant)),
                Text(
                  formatSleepDuration(night.durationMinutes),
                  style: routineMetricStyle.copyWith(color: colors.onSurface),
                ),
                Text('Tiempo total de sueño', style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String detail;

  const new({required this.label, required this.value, required this.detail});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return RoutineCard(
      children: [
        Text(label.toUpperCase(), style: text.labelSmall?.copyWith(color: colors.onSurfaceVariant)),
        Text(value, style: routineMetricStyle.copyWith(color: colors.onSurface)),
        Text(detail, style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
      ],
    );
  }
}

/// One row per night: weekday, time asleep and continuity.
class _SleepHistoryCard extends StatelessWidget {
  final List<SleepCycleRecord> nights;

  const new({required this.nights});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return RoutineCard(
      children: [
        for (final (index, night) in nights.indexed) ...[
          if (index > 0) Divider(color: colors.surfaceContainerHighest),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(formatShortWeekday(night.endTime), style: text.titleSmall?.copyWith(color: colors.onSurface)),
                ),
                SizedBox(
                  width: 84,
                  child: Text(
                    formatSleepDuration(night.durationMinutes),
                    style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ),
                Expanded(
                  child: RoutineProgressBar(
                    percentage: night.continuityScore,
                    progress: night.classification == SleepClassification.fragmented
                        ? colors.tertiary
                        : colors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ClassificationBadge extends StatelessWidget {
  final SleepClassification classification;

  const new({required this.classification});

  @override
  Widget build(BuildContext context) {
    if (classification == SleepClassification.fragmented) {
      return const RoutineBadge(text: 'Fragmentado', tone: RoutineTone.orange);
    }
    return const RoutineBadge(text: 'Regular');
  }
}
