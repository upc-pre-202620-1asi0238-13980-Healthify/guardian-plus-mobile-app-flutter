import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/local_time.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/recurrence_frequency.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_banner.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_form_fields.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_form_layout.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_labels.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_message.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_top_bar.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/medication_form/medication_form_view_model.dart';

// Same limit as the platform's ScheduleReminderResource
const _maxTextLength = 255;

const _frequencies = [RecurrenceFrequency.daily, RecurrenceFrequency.weekly, RecurrenceFrequency.once];

// Indications of the prototype, plus none
const _noInstructions = 'Sin indicaciones';
const _instructionOptions = ['Después del almuerzo', 'Antes de comer', 'Con alimentos', 'En ayunas', _noInstructions];

/// "Nueva toma". Goes back with the confirmation to show once the platform scheduled the dose.
class MedicationFormPage extends StatefulWidget {
  final MedicationFormViewModel viewModel;

  const new({super.key, required this.viewModel});

  @override
  State<MedicationFormPage> createState() => _MedicationFormPageState();
}

class _MedicationFormPageState extends State<MedicationFormPage> {
  late final MedicationFormViewModel _viewModel = widget.viewModel;

  // What the user is typing is purely visual state, so it lives here and not in the view model
  String _name = '';
  String _dosage = '';
  RecurrenceFrequency _frequency = RecurrenceFrequency.daily;
  Set<int> _days = {};
  LocalTime _time = const LocalTime(hour: 8, minute: 0);
  String _instruction = _instructionOptions.first;
  // Errors only show after the first attempt, so an empty form does not start in red
  bool _showErrors = false;

  bool get _nameValid => _name.trim().isNotEmpty;

  bool get _daysValid => _frequency != RecurrenceFrequency.weekly || _days.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_goBackWhenSaved);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_goBackWhenSaved);
    // The page owns its view model: every visit starts with a fresh one (registerFactory)
    _viewModel.dispose();
    super.dispose();
  }

  void _goBackWhenSaved() {
    final savedTime = _viewModel.state.savedTime;
    if (savedTime == null || !mounted) return;
    Navigator.pop(context, 'Recordatorio programado para las ${formatTimeOfDay(savedTime)}');
  }

  void _save() {
    setState(() => _showErrors = true);
    if (!_nameValid || !_daysValid) return;
    _viewModel.save(
      name: _name,
      dosage: _dosage,
      frequency: _frequency,
      days: _days,
      time: _time,
      instructions: _instruction == _noInstructions ? null : _instruction,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RoutineTopBar(
        title: 'Nueva toma',
        subtitle: 'Programa un medicamento',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: RoutineMessageEffect(
        source: _viewModel,
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) => RoutineFormBody(
            saveLabel: 'Guardar recordatorio',
            isSaving: _viewModel.state.isSaving,
            onSave: _save,
            children: [
              RoutineFormSection(
                title: 'Medicamento',
                children: [
                  RoutineTextField(
                    label: 'Nombre',
                    value: _name,
                    onChanged: (value) => setState(() => _name = value),
                    placeholder: 'Ej. Losartán',
                    errorMessage: _showErrors && !_nameValid ? 'Escribe el nombre del medicamento' : null,
                    maxLength: _maxTextLength,
                    capitalization: TextCapitalization.words,
                  ),
                  RoutineTextField(
                    label: 'Dosis',
                    value: _dosage,
                    onChanged: (value) => _dosage = value,
                    placeholder: 'Ej. 50 mg',
                    maxLength: _maxTextLength,
                  ),
                  RoutineSelectField<RecurrenceFrequency>(
                    label: 'Frecuencia',
                    options: _frequencies,
                    selected: _frequency,
                    optionLabel: _frequencyLabel,
                    onSelect: (frequency) => setState(() => _frequency = frequency),
                  ),
                  if (_frequency == RecurrenceFrequency.weekly)
                    _WeekdayPicker(
                      selected: _days,
                      showError: _showErrors && !_daysValid,
                      onToggle: (day) => setState(() {
                        _days = _days.contains(day) ? ({..._days}..remove(day)) : {..._days, day};
                      }),
                    ),
                ],
              ),
              RoutineFormSection(
                title: 'Horario',
                children: [
                  RoutineTimeField(
                    label: 'Hora de la toma',
                    value: _time,
                    onChanged: (time) => setState(() => _time = time),
                  ),
                  RoutineSelectField<String>(
                    label: 'Indicaciones',
                    options: _instructionOptions,
                    selected: _instruction,
                    optionLabel: (option) => option,
                    onSelect: (option) => setState(() => _instruction = option),
                  ),
                ],
              ),
              const RoutineFormSection(
                title: 'Aviso en la pulsera',
                children: [
                  RoutineInfoLine(
                    icon: Icons.schedule,
                    text: 'Si no se confirma en 10 min, se repetirá el aviso y recibirás una notificación.',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _frequencyLabel(RecurrenceFrequency frequency) {
  return switch (frequency) {
    RecurrenceFrequency.daily => 'Todos los días',
    RecurrenceFrequency.weekly => 'Días específicos',
    RecurrenceFrequency.once => 'Una sola vez',
  };
}

/// Chips "L M X J V S D" for "Días específicos".
class _WeekdayPicker extends StatelessWidget {
  final Set<int> selected;
  final bool showError;
  final ValueChanged<int> onToggle;

  const new({required this.selected, required this.showError, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var day = DateTime.monday; day <= DateTime.sunday; day++)
              FilterChip(
                selected: selected.contains(day),
                onSelected: (_) => onToggle(day),
                label: Text(weekdayInitial(day)),
                showCheckmark: false,
                shape: const StadiumBorder(),
                selectedColor: colors.primary,
                labelStyle: TextStyle(color: selected.contains(day) ? colors.onPrimary : colors.onSurface),
              ),
          ],
        ),
        if (showError)
          Text(
            'Elige al menos un día',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.error),
          ),
      ],
    );
  }
}
