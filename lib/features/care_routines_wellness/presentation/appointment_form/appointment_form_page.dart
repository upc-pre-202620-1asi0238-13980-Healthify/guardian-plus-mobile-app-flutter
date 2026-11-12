import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/local_time.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/appointment_form/appointment_form_view_model.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_banner.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_day.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_form_fields.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_form_layout.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_labels.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_message.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_tone.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_top_bar.dart';

// Same limit as the platform's ScheduleReminderResource
const _maxTextLength = 255;

// "Recordar": 1 hora, 2 horas or 1 día antes, as lead time in minutes
const _leadTimes = [60, 120, 1440];

/// "Nueva cita". Goes back with the confirmation to show once the platform scheduled the appointment.
class AppointmentFormPage extends StatefulWidget {
  final AppointmentFormViewModel viewModel;

  const new({super.key, required this.viewModel});

  @override
  State<AppointmentFormPage> createState() => _AppointmentFormPageState();
}

class _AppointmentFormPageState extends State<AppointmentFormPage> {
  late final AppointmentFormViewModel _viewModel = widget.viewModel;

  late final DateTime _today = todayBounds(DateTime.now()).$1;
  String _specialty = '';
  late DateTime _date = DateTime(_today.year, _today.month, _today.day + 1);
  LocalTime _time = const LocalTime(hour: 10, minute: 0);
  String _location = '';
  int _leadTime = _leadTimes.first;
  bool _showErrors = false;

  bool get _specialtyValid => _specialty.trim().isNotEmpty;

  DateTime get _dateTime => atTime(_date, _time);

  bool get _inFuture => _dateTime.isAfter(DateTime.now());

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
    if (!_viewModel.state.saved || !mounted) return;
    Navigator.pop(context, 'Cita agendada correctamente');
  }

  void _save() {
    setState(() => _showErrors = true);
    if (!_specialtyValid || !_inFuture) return;
    _viewModel.save(specialty: _specialty, dateTime: _dateTime, location: _location, leadTimeMinutes: _leadTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RoutineTopBar(
        title: 'Nueva cita',
        subtitle: 'Agenda un control médico',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: RoutineMessageEffect(
        source: _viewModel,
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) => RoutineFormBody(
            saveLabel: 'Agendar cita',
            isSaving: _viewModel.state.isSaving,
            onSave: _save,
            children: [
              RoutineFormSection(
                children: [
                  RoutineTextField(
                    label: 'Especialidad o motivo',
                    value: _specialty,
                    onChanged: (value) => setState(() => _specialty = value),
                    placeholder: 'Ej. Cardiología',
                    errorMessage: _showErrors && !_specialtyValid ? 'Escribe la especialidad o el motivo' : null,
                    maxLength: _maxTextLength,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 13,
                        child: RoutineDateField(
                          label: 'Fecha',
                          value: _date,
                          minDate: _today,
                          onChanged: (date) => setState(() => _date = date),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 10,
                        child: RoutineTimeField(
                          label: 'Hora',
                          value: _time,
                          errorMessage: _showErrors && !_inFuture ? 'Elige una hora futura' : null,
                          onChanged: (time) => setState(() => _time = time),
                        ),
                      ),
                    ],
                  ),
                  RoutineTextField(
                    label: 'Centro médico',
                    value: _location,
                    onChanged: (value) => _location = value,
                    placeholder: 'Ej. Clínica San Gabriel',
                    maxLength: _maxTextLength,
                    capitalization: TextCapitalization.words,
                  ),
                  RoutineSelectField<int>(
                    label: 'Recordar',
                    options: _leadTimes,
                    selected: _leadTime,
                    optionLabel: leadTimeLabel,
                    onSelect: (leadTime) => setState(() => _leadTime = leadTime),
                  ),
                ],
              ),
              RoutineBanner(
                icon: Icons.notifications_none,
                title: 'Aviso preventivo',
                message: '${_viewModel.careRecipientFirstName} recibirá el aviso en la pulsera antes de la cita.',
                tone: RoutineTone.mint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
