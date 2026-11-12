import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/care_routines_wellness/presentation/common/routine_card.dart';

/// Scrollable body of a form with its save button always visible at the bottom.
class RoutineFormBody extends StatelessWidget {
  final String saveLabel;
  final bool isSaving;
  final VoidCallback onSave;
  final List<Widget> children;

  const new({
    super.key,
    required this.saveLabel,
    required this.isSaving,
    required this.onSave,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            itemCount: children.length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) => children[index],
          ),
        ),
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: SafeArea(
            top: false,
            child: RoutinePrimaryButton(text: saveLabel, isLoading: isSaving, onPressed: onSave),
          ),
        ),
      ],
    );
  }
}

/// Full-width green pill button of the prototype, with progress while the platform answers.
class RoutinePrimaryButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;

  const new({super.key, required this.text, this.isLoading = false, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48), shape: const StadiumBorder()),
      child: isLoading
          ? SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary),
            )
          : Text(text),
    );
  }
}

/// Titled card grouping the fields of one part of a form ("Medicamento", "Horario"…).
class RoutineFormSection extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const new({super.key, this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) ...[RoutineSectionTitle(text: title!), const SizedBox(height: 10)],
        RoutineCard(
          children: [
            for (final (index, child) in children.indexed) ...[
              if (index > 0) const SizedBox(height: 14),
              child,
            ],
          ],
        ),
      ],
    );
  }
}
