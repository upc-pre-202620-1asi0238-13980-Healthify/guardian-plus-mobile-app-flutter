import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardian_plus_app/core/service_locator.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/main/main_page.dart';
import 'package:guardian_plus_app/features/profile/domain/care_relationship.dart';
import 'package:guardian_plus_app/features/profile/presentation/onboarding/onboarding_viewmodel.dart';
import 'package:guardian_plus_app/l10n/l10n.dart';

class OnboardingPage extends StatefulWidget {
  final String userAccountId;
  final bool needsUserProfile;
  final bool needsCareRecipient;
  final String? suggestedFullName;

  const OnboardingPage({
    super.key,
    required this.userAccountId,
    required this.needsUserProfile,
    required this.needsCareRecipient,
    this.suggestedFullName,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final OnboardingViewModel viewModel;

  final firstNameController = TextEditingController();

  final lastNameController = TextEditingController();

  final phoneController = TextEditingController();

  final careRecipientFirstNameController = TextEditingController();

  final careRecipientLastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    viewModel = getIt<OnboardingViewModel>();

    viewModel.start(
      needsUserProfile: widget.needsUserProfile,
      needsCareRecipient: widget.needsCareRecipient,
      suggestedFullName: widget.suggestedFullName,
    );

    firstNameController.text = viewModel.state.firstName;

    lastNameController.text = viewModel.state.lastName;
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    careRecipientFirstNameController.dispose();
    careRecipientLastNameController.dispose();

    viewModel.dispose();

    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final state = viewModel.state;

    final initialDate = state.careRecipientBirthDate ?? DateTime(1950, 1, 1);

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime.now(),
    );

    if (selected == null || !mounted) {
      return;
    }

    viewModel.onCareRecipientBirthDateChanged(selected);
  }

  Future<void> _submit() async {
    final completed = await viewModel.submit(
      userAccountId: widget.userAccountId,
    );

    if (!mounted || !completed) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final state = viewModel.state;
        final l10n = context.l10n;

        return Scaffold(
          backgroundColor: AppColors.hero,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(38),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.person_add_alt_1_outlined,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.onboardingCompleteProfile,
                          style: TextStyle(
                            fontSize: 34,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.onboardingHeroSubtitle,
                          style: TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 28, 22, 32),
                  decoration: const BoxDecoration(
                    color: AppColors.sheet,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.onboardingConfigureAccount,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.onboardingExperienceInfo,
                        style: TextStyle(color: AppColors.textMuted),
                      ),

                      if (state.showUserProfile) ...[
                        _sectionTitle(l10n.onboardingYourData.toUpperCase()),
                        _fieldLabel(l10n.profileFirstNames.toUpperCase()),
                        const SizedBox(height: 8),
                        TextField(
                          controller: firstNameController,
                          textCapitalization: TextCapitalization.words,
                          onChanged: viewModel.onFirstNameChanged,
                          decoration: _inputDecoration(
                            l10n.onboardingFirstNameHint,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _fieldLabel(l10n.profileLastNames.toUpperCase()),
                        const SizedBox(height: 8),
                        TextField(
                          controller: lastNameController,
                          textCapitalization: TextCapitalization.words,
                          onChanged: viewModel.onLastNameChanged,
                          decoration: _inputDecoration(
                            l10n.onboardingLastNameHint,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _fieldLabel(l10n.profilePhone.toUpperCase()),
                        const SizedBox(height: 8),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9+\s]'),
                            ),
                          ],
                          onChanged: viewModel.onPhoneNumberChanged,
                          decoration: _inputDecoration('+51987654321'),
                        ),
                      ],

                      if (state.showCareRecipient) ...[
                        _sectionTitle(l10n.profileCareRecipient.toUpperCase()),
                        _fieldLabel(l10n.profileFirstNames.toUpperCase()),
                        const SizedBox(height: 8),
                        TextField(
                          controller: careRecipientFirstNameController,
                          textCapitalization: TextCapitalization.words,
                          onChanged: viewModel.onCareRecipientFirstNameChanged,
                          decoration: _inputDecoration(
                            l10n.onboardingRecipientFirstNameHint,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _fieldLabel(l10n.profileLastNames.toUpperCase()),
                        const SizedBox(height: 8),
                        TextField(
                          controller: careRecipientLastNameController,
                          textCapitalization: TextCapitalization.words,
                          onChanged: viewModel.onCareRecipientLastNameChanged,
                          decoration: _inputDecoration(
                            l10n.onboardingRecipientLastNameHint,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _fieldLabel(l10n.careRecipientBirthDate.toUpperCase()),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _selectBirthDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    state.careRecipientBirthDate == null
                                        ? l10n.careRecipientSelectDate
                                        : _formatDate(
                                            state.careRecipientBirthDate!,
                                          ),
                                    style: TextStyle(
                                      color:
                                          state.careRecipientBirthDate == null
                                          ? AppColors.textMuted
                                          : AppColors.textDark,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.calendar_month_outlined,
                                  size: 20,
                                  color: AppColors.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _fieldLabel(l10n.onboardingRelationship.toUpperCase()),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _relationshipButton(
                                text: l10n.relationshipFamily,
                                selected:
                                    state.relationshipType ==
                                    RelationshipType.family,
                                onPressed: () {
                                  viewModel.onRelationshipTypeChanged(
                                    RelationshipType.family,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _relationshipButton(
                                text: l10n.relationshipCaregiver,
                                selected:
                                    state.relationshipType ==
                                    RelationshipType.caregiver,
                                onPressed: () {
                                  viewModel.onRelationshipTypeChanged(
                                    RelationshipType.caregiver,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],

                      if (state.errorMessage != null) ...[
                        const SizedBox(height: 18),
                        Text(
                          state.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],

                      const SizedBox(height: 26),

                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: FilledButton(
                          onPressed: state.isLoading ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: state.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  l10n.commonContinue,
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 14),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
        color: AppColors.textMuted,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    );

    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: AppColors.textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  Widget _relationshipButton({
    required String text,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 46,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: selected ? AppColors.primary : AppColors.textDark,
          backgroundColor: Colors.white,
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
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
