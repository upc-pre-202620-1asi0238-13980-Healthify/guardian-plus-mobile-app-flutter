import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_card.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_labels.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_screen_states.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/navigation/care_routines_wellness_navigation.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/routines/components/next_routine_card.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/routines/components/routine_category_card.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/routines/components/routines_header.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/routines/components/today_progress_card.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/routines/components/wristband_sync_note.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/routines/routine_category.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/routines/routines_state.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/routines/routines_view_model.dart';

/// Routines tab of the bottom bar: today's progress, what comes next and every routine of Care Routines.
class RoutinesPage extends StatefulWidget {
  final RoutinesViewModel viewModel;

  const new({super.key, required this.viewModel});

  @override
  State<RoutinesPage> createState() => _RoutinesPageState();
}

class _RoutinesPageState extends State<RoutinesPage> {
  late final RoutinesViewModel _viewModel = widget.viewModel;

  @override
  void dispose() {
    // The page owns its view model: every visit starts with a fresh one (registerFactory)
    _viewModel.dispose();
    super.dispose();
  }

  // Coming back from a routine screen, the day may have changed there
  Future<void> _openCategory(RoutineCategory category) async {
    await openRoutineCategory(context, category);
    _viewModel.onScreenShown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          final state = _viewModel.state;
          return Column(
            children: [
              RoutinesHeader(userInitials: _viewModel.userInitials, careRecipientName: state.careRecipientName),
              Expanded(
                child: switch (state) {
                  // Old data stays visible during refreshes; the spinner is only for the very first load
                  RoutinesState(isLoaded: false, errorMessage: null) => const RoutineLoadingState(),
                  RoutinesState(isLoaded: false) => RoutineErrorState(
                    message: state.errorMessage ?? '',
                    onRetry: _viewModel.load,
                  ),
                  _ => _RoutinesList(state: state, onCategoryTap: _openCategory),
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RoutinesList extends StatelessWidget {
  final RoutinesState state;
  final ValueChanged<RoutineCategory> onCategoryTap;

  const new({required this.state, required this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    final next = state.nextReminder;
    final lastSyncAt = state.activityMonitor?.lastSampleAt;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        TodayProgressCard(dateLabel: formatWeekdayAndDay(state.now), count: state.today),
        if (next != null) ...[
          const RoutineSectionTitle(text: 'Siguiente', topPadding: 24),
          const SizedBox(height: 10),
          NextRoutineCard(
            reminder: next,
            now: state.now,
            onTap: () => onCategoryTap(RoutineCategory.of(next.type)),
          ),
        ],
        const RoutineSectionTitle(text: 'Todas las rutinas', topPadding: 24),
        for (final category in RoutineCategory.values) ...[
          const SizedBox(height: 10),
          RoutineCategoryCard(
            category: category,
            summary: state.summaryOf(category),
            onTap: () => onCategoryTap(category),
          ),
        ],
        if (lastSyncAt != null) ...[
          const SizedBox(height: 24),
          WristbandSyncNote(lastSyncAt: lastSyncAt, now: state.now),
        ],
      ],
    );
  }
}
