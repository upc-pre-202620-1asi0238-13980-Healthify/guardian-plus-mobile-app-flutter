import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/hydration_plan.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_banner.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_card.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_form_fields.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_labels.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_message.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_progress_bar.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_screen_states.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_settings_card.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_tone.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_top_bar.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/hydration/hydration_state.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/hydration/hydration_view_model.dart';

// "Meta diaria de agua" and "Intervalo" options of the prototype, inside the platform's 1–20 and 1–12
const _goalOptions = [4, 5, 6, 7, 8, 9, 10];
const _intervalOptions = [1, 2, 3];

class HydrationPage extends StatefulWidget {
  final HydrationViewModel viewModel;

  const new({super.key, required this.viewModel});

  @override
  State<HydrationPage> createState() => _HydrationPageState();
}

class _HydrationPageState extends State<HydrationPage> {
  late final HydrationViewModel _viewModel = widget.viewModel;

  @override
  void dispose() {
    // The page owns its view model: every visit starts with a fresh one (registerFactory)
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RoutineTopBar(
        title: 'Hidratación',
        subtitle: 'Recordatorios periódicos',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: RoutineMessageEffect(
        source: _viewModel,
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) {
            final state = _viewModel.state;
            return switch (state) {
              HydrationState(isLoaded: false, errorMessage: null) => const RoutineLoadingState(),
              HydrationState(isLoaded: false) => RoutineErrorState(
                message: state.errorMessage ?? '',
                onRetry: _viewModel.load,
              ),
              _ => ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  _HydrationHeroCard(plan: state.plan, goal: state.settings.dailyGoalGlasses),
                  const SizedBox(height: 10),
                  const RoutineSectionTitle(text: 'Configuración'),
                  const SizedBox(height: 10),
                  _HydrationSettingsCard(state: state, viewModel: _viewModel),
                  if (state.settings.respectSleepWindow) ...[
                    const SizedBox(height: 10),
                    const RoutineBanner(
                      icon: Icons.bedtime_outlined,
                      title: 'Modo descanso configurado',
                      message: 'Los ciclos que venzan durante la noche se omitirán automáticamente.',
                      tone: RoutineTone.mint,
                    ),
                  ],
                ],
              ),
            };
          },
        ),
      ),
    );
  }
}

/// Water ring "4 de 6 vasos", what is left for the goal and when the next reminder is due.
class _HydrationHeroCard extends StatelessWidget {
  final HydrationPlan? plan;
  final int goal;

  const new({required this.plan, required this.goal});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final plan = this.plan;
    final consumed = plan?.glassesConsumedToday ?? 0;
    final remaining = plan?.remainingGlassesToday ?? goal;
    final nextReminderAt = plan?.nextReminderAt;

    final status = plan == null
        ? 'Configura el plan para empezar los recordatorios'
        : !plan.active
        ? 'Recordatorios en pausa'
        : nextReminderAt != null
        ? 'Próximo recordatorio a las ${formatClockTime(nextReminderAt)}'
        : 'Sin recordatorios pendientes hoy';

    return RoutineCard(
      children: [
        Row(
          children: [
            _WaterRing(consumed: consumed, goal: goal),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('META DE HOY', style: dataLabelStyle.copyWith(color: colors.onSurfaceVariant)),
                  Text(
                    remaining > 0 ? plural(remaining, 'Falta $remaining vaso', 'Faltan $remaining vasos') : 'Meta completada',
                    style: text.titleMedium?.copyWith(color: colors.onSurface),
                  ),
                  Text(status, style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
                  const SizedBox(height: 12),
                  RoutineProgressBar(percentage: plan?.progressPercentage ?? 0),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WaterRing extends StatelessWidget {
  final int consumed;
  final int goal;

  const new({required this.consumed, required this.goal});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        shape: BoxShape.circle,
        border: Border.all(color: colors.secondary, width: 6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.water_drop_outlined, size: 28, color: colors.primary),
          Text(
            '$consumed',
            style: text.titleLarge?.copyWith(
              fontFamily: GuardianFonts.data,
              fontWeight: FontWeight.w700,
              fontSize: 23,
              color: colors.primary,
            ),
          ),
          Text(
            plural(goal, 'de $goal vaso', 'de $goal vasos'),
            style: text.labelSmall?.copyWith(fontWeight: FontWeight.w400, fontSize: 9, color: colors.primary),
          ),
        ],
      ),
    );
  }
}

class _HydrationSettingsCard extends StatelessWidget {
  final HydrationState state;
  final HydrationViewModel viewModel;

  const new({required this.state, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final settings = state.settings;
    final enabled = !state.isSaving;
    final sleepStart = state.plan?.sleepWindowStart;
    final sleepEnd = state.plan?.sleepWindowEnd;

    return RoutineSettingsCard(
      children: [
        RoutineSwitchRow(
          title: 'Recordatorios activos',
          detail: 'Avisar cada ${settings.intervalHours * 60} min',
          value: settings.active,
          enabled: enabled,
          onChanged: viewModel.setActive,
        ),
        RoutineSelectField<int>(
          padding: routineSettingsRowPadding,
          label: 'Meta diaria de agua',
          // A goal set elsewhere (e.g. 12 through the API) still shows as selected
          options: ({..._goalOptions, settings.dailyGoalGlasses}.toList()..sort()),
          selected: settings.dailyGoalGlasses,
          optionLabel: (glasses) => plural(glasses, '$glasses vaso', '$glasses vasos'),
          enabled: enabled,
          onSelect: viewModel.setDailyGoal,
        ),
        RoutineSelectField<int>(
          padding: routineSettingsRowPadding,
          label: 'Intervalo',
          options: ({..._intervalOptions, settings.intervalHours}.toList()..sort()),
          selected: settings.intervalHours,
          optionLabel: hydrationIntervalLabel,
          enabled: enabled,
          onSelect: viewModel.setInterval,
        ),
        RoutineSwitchRow(
          title: 'Respetar horas de sueño',
          detail: sleepStart != null && sleepEnd != null
              ? 'No emitir avisos de ${formatTimeOfDay(sleepStart)} a ${formatTimeOfDay(sleepEnd)}'
              : 'No emitir avisos durante la noche',
          value: settings.respectSleepWindow,
          enabled: enabled,
          onChanged: viewModel.setRespectSleepWindow,
        ),
      ],
    );
  }
}
