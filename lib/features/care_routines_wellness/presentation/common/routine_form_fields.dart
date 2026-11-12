import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/domain/local_time.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_labels.dart';

/// Small muted label above a form field, as in the prototype.
class _FieldLabel extends StatelessWidget {
  final String text;

  const new(this.text);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Text(text, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colors.onSurfaceVariant));
  }
}

/// Free-text field with its label above. The parent keeps the text; [value] only seeds the field.
class RoutineTextField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String? placeholder;
  final String? errorMessage;
  final int maxLength;
  final TextCapitalization capitalization;

  const new({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.placeholder,
    this.errorMessage,
    this.maxLength = 255,
    this.capitalization = TextCapitalization.sentences,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 7),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          textCapitalization: capitalization,
          textInputAction: TextInputAction.next,
          inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
          decoration: InputDecoration(
            hintText: placeholder,
            errorText: errorMessage,
            filled: true,
            fillColor: Theme.of(context).scaffoldBackgroundColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GuardianRadius.medium),
              borderSide: BorderSide(color: colors.outline),
            ),
          ),
        ),
      ],
    );
  }
}

/// Read-only field that opens a picker or a menu when tapped.
class _PickerBox extends StatelessWidget {
  final String value;
  final IconData icon;
  final bool isError;
  final VoidCallback? onTap;

  const new({required this.value, required this.icon, this.isError = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final box = Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(GuardianRadius.medium),
        border: Border.all(color: isError ? colors.error : colors.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colors.onSurface)),
          ),
          Icon(icon, size: 18, color: colors.onSurfaceVariant),
        ],
      ),
    );
    if (onTap == null) return box;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(GuardianRadius.medium), child: box);
  }
}

/// Closed list of options ("Todos los días", "1 hora antes"…), like the prototype's select.
class RoutineSelectField<T> extends StatelessWidget {
  final String label;
  final List<T> options;
  final T selected;
  final String Function(T option) optionLabel;
  final bool enabled;
  final ValueChanged<T> onSelect;
  final EdgeInsetsGeometry padding;

  const new({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.optionLabel,
    this.enabled = true,
    required this.onSelect,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FieldLabel(label),
          const SizedBox(height: 7),
          PopupMenuButton<T>(
            enabled: enabled,
            tooltip: label,
            onSelected: (option) {
              if (option != selected) onSelect(option);
            },
            itemBuilder: (context) => [
              for (final option in options) PopupMenuItem<T>(value: option, child: Text(optionLabel(option))),
            ],
            child: _PickerBox(value: optionLabel(selected), icon: Icons.keyboard_arrow_down),
          ),
        ],
      ),
    );
  }
}

/// Time of day in 24 h, picked on the Material clock.
class RoutineTimeField extends StatelessWidget {
  final String label;
  final LocalTime value;
  final String? errorMessage;
  final ValueChanged<LocalTime> onChanged;

  const new({super.key, required this.label, required this.value, this.errorMessage, required this.onChanged});

  Future<void> _pick(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: value.hour, minute: value.minute),
      confirmText: 'Aceptar',
      cancelText: 'Cancelar',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) onChanged(LocalTime(hour: picked.hour, minute: picked.minute));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 7),
        _PickerBox(
          value: formatTimeOfDay(value),
          icon: Icons.schedule,
          isError: errorMessage != null,
          onTap: () => _pick(context),
        ),
        if (errorMessage != null)
          Text(errorMessage!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.error)),
      ],
    );
  }
}

/// Calendar day from [minDate] on, for appointments.
class RoutineDateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final DateTime minDate;
  final ValueChanged<DateTime> onChanged;

  const new({super.key, required this.label, required this.value, required this.minDate, required this.onChanged});

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: minDate,
      lastDate: DateTime(minDate.year + 5, minDate.month, minDate.day),
      confirmText: 'Aceptar',
      cancelText: 'Cancelar',
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 7),
        _PickerBox(value: formatFullDate(value), icon: Icons.calendar_today_outlined, onTap: () => _pick(context)),
      ],
    );
  }
}
