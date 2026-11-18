import 'package:flutter/material.dart';
import 'package:guardian_plus_app/features/profile/domain/user_profile.dart';
import 'package:guardian_plus_app/features/profile/presentation/common/profile_ui.dart';
import 'package:guardian_plus_app/features/profile/presentation/personal_data/personal_data_view_model.dart';

class PersonalDataPage extends StatefulWidget {
  final PersonalDataViewModel viewModel;
  final VoidCallback onBack;
  final ValueChanged<UserProfile>? onProfileUpdated;

  const PersonalDataPage({
    super.key,
    required this.viewModel,
    required this.onBack,
    this.onProfileUpdated,
  });

  @override
  State<PersonalDataPage> createState() => _PersonalDataPageState();
}

class _PersonalDataPageState extends State<PersonalDataPage> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;

  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();

    widget.viewModel.addListener(_handleViewModelChange);
    widget.viewModel.load();
  }

  void _handleViewModelChange() {
    if (!_controllersInitialized && widget.viewModel.profile != null) {
      final profile = widget.viewModel.profile!;

      _firstNameController.text = profile.firstName;
      _lastNameController.text = profile.lastName;
      _phoneController.text = profile.phoneNumber;

      _controllersInitialized = true;
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_handleViewModelChange);

    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    final result = await widget.viewModel.save(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phoneNumber: _phoneController.text,
    );

    if (result != null) {
      widget.onProfileUpdated?.call(result);
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
                    title: 'Mis datos',
                    subtitle: 'Información personal y contacto',
                    onBack: widget.onBack,
                  ),
                  const SizedBox(height: 24),

                  const ProfileSectionTitle(title: 'Información personal'),

                  ProfileCard(
                    child: Column(
                      children: [
                        _ProfileTextField(
                          controller: _firstNameController,
                          label: 'Nombres',
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 16),
                        _ProfileTextField(
                          controller: _lastNameController,
                          label: 'Apellidos',
                          icon: Icons.badge_outlined,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  const ProfileSectionTitle(title: 'Contacto'),

                  ProfileCard(
                    child: _ProfileTextField(
                      controller: _phoneController,
                      label: 'Teléfono',
                      keyboardType: TextInputType.phone,
                      icon: Icons.phone_outlined,
                    ),
                  ),

                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _MessageCard(message: state.errorMessage!, error: true),
                  ],

                  if (state.successMessage != null) ...[
                    const SizedBox(height: 16),
                    _MessageCard(message: state.successMessage!),
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
                    text: 'Mantén actualizados tus datos para facilitar la comunicación dentro de Guardian+.',
                  ),
                ],
              ),
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  const _ProfileTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String message;
  final bool error;

  const _MessageCard({required this.message, this.error = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final foreground = error
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

    final background = error
        ? theme.colorScheme.errorContainer
        : theme.colorScheme.secondaryContainer;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            error
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: foreground,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: TextStyle(color: foreground)),
          ),
        ],
      ),
    );
  }
}
