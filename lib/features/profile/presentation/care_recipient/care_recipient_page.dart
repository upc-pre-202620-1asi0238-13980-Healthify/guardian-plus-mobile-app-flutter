import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/profile/domain/care_recipient.dart';
import 'package:guardian_plus_app/features/profile/presentation/care_recipient/care_recipient_view_model.dart';
import 'package:guardian_plus_app/features/profile/presentation/common/profile_ui.dart';

class CareRecipientPage extends StatefulWidget {
  final CareRecipientViewModel viewModel;
  final VoidCallback onBack;
  final ValueChanged<CareRecipient>? onCareRecipientUpdated;

  const CareRecipientPage({
    super.key,
    required this.viewModel,
    required this.onBack,
    this.onCareRecipientUpdated,
  });

  @override
  State<CareRecipientPage> createState() => _CareRecipientPageState();
}

class _CareRecipientPageState extends State<CareRecipientPage> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;

  DateTime? _birthDate;
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();

    widget.viewModel.addListener(_handleChange);
    widget.viewModel.load();
  }

  void _handleChange() {
    final recipient = widget.viewModel.recipient;

    if (!_controllersInitialized && recipient != null) {
      _firstNameController.text = recipient.firstName;
      _lastNameController.text = recipient.lastName;
      _birthDate = recipient.birthDate;

      _controllersInitialized = true;
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_handleChange);

    _firstNameController.dispose();
    _lastNameController.dispose();

    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 70),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (selected != null) {
      setState(() {
        _birthDate = selected;
      });
    }
  }

  Future<void> _save() async {
    final birthDate = _birthDate;

    if (birthDate == null) {
      return;
    }

    final result = await widget.viewModel.save(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      birthDate: birthDate,
    );

    if (result != null) {
      widget.onCareRecipientUpdated?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = widget.viewModel;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                children: [
                  ProfileTopBar(
                    title: 'Persona bajo cuidado',
                    subtitle: 'Información de la persona que acompañas',
                    onBack: widget.onBack,
                  ),

                  const SizedBox(height: 24),

                  const ProfileSectionTitle(title: 'Información personal'),

                  ProfileCard(
                    child: Column(
                      children: [
                        TextField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: 'Nombres',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: 'Apellidos',
                            prefixIcon: const Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        InkWell(
                          onTap: _selectBirthDate,
                          borderRadius: BorderRadius.circular(12),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Fecha de nacimiento',
                              prefixIcon: const Icon(
                                Icons.calendar_today_outlined,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _birthDate == null
                                  ? 'Seleccionar fecha'
                                  : _formatDate(_birthDate!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _StatusMessage(message: state.errorMessage!, error: true),
                  ],

                  if (state.successMessage != null) ...[
                    const SizedBox(height: 16),
                    _StatusMessage(message: state.successMessage!),
                  ],

                  const SizedBox(height: 24),

                  FilledButton(
                    onPressed: state.isSaving ? null : _save,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state.isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Guardar cambios'),
                  ),

                  const SizedBox(height: 14),

                  const ProfileInfoBanner(
                    text: 'Esta información ayuda a identificar correctamente a la persona bajo cuidado dentro de Guardian+.',
                  ),
                ],
              ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}

class _StatusMessage extends StatelessWidget {
  final String message;
  final bool error;

  const _StatusMessage({required this.message, this.error = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color = error ? theme.colorScheme.error : theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: error
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            error ? Icons.error_outline : Icons.check_circle_outline,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }
}
