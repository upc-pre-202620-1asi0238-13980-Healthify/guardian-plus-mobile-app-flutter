import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/auth/domain/otp_purpose.dart';
import 'package:guardian_plus_app/features/auth/presentation/otp/otp_verification_page.dart';
import 'package:guardian_plus_app/features/auth/presentation/register/register_viewmodel.dart';
import 'package:guardian_plus_app/l10n/l10n.dart';
import 'package:guardian_plus_app/features/auth/presentation/auth_message_localizer.dart';

class RegisterPage extends StatefulWidget {
  final RegisterViewmodel viewModel;

  const RegisterPage({super.key, required this.viewModel});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final fullNameController = TextEditingController();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    widget.viewModel.dispose();

    super.dispose();
  }

  Future<void> _register() async {
    final navigation = await widget.viewModel.register(
      fullName: fullNameController.text,
      email: emailController.text,
      password: passwordController.text,
      confirmPassword: confirmPasswordController.text,
    );

    if (!mounted || navigation == null) {
      return;
    }

    passwordController.clear();
    confirmPasswordController.clear();

    final verified = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OtpVerificationPage(
          userAccountId: navigation.userAccountId,
          email: navigation.email,
          purpose: OtpPurpose.emailVerification,
        ),
      ),
    );

    if (!mounted || verified != true) {
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final state = widget.viewModel.state;

        return Scaffold(
          backgroundColor: AppColors.sheet,
          appBar: AppBar(
            backgroundColor: AppColors.sheet,
            title: Text(context.l10n.authCreateAccount),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              children: [
                const Icon(
                  Icons.health_and_safety_outlined,
                  size: 54,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 18),
                Text(
                  context.l10n.registerJoin,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.registerSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 30),
                _label(context.l10n.registerFullName.toUpperCase()),
                const SizedBox(height: 8),
                TextField(
                  controller: fullNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDecoration(
                    context.l10n.registerFullNameHint,
                  ),
                ),
                const SizedBox(height: 18),
                _label(context.l10n.authEmail.toUpperCase()),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(context.l10n.authEmailHint),
                ),
                const SizedBox(height: 18),
                _label(context.l10n.authPassword.toUpperCase()),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  obscureText: state.isPasswordHidden,
                  decoration:
                      _inputDecoration(
                        context.l10n.registerPasswordHint,
                      ).copyWith(
                        suffixIcon: IconButton(
                          onPressed: widget.viewModel.togglePasswordVisibility,
                          icon: Icon(
                            state.isPasswordHidden
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                ),
                const SizedBox(height: 18),
                _label(context.l10n.registerConfirmPassword.toUpperCase()),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: state.isConfirmPasswordHidden,
                  decoration:
                      _inputDecoration(
                        context.l10n.registerConfirmPasswordHint,
                      ).copyWith(
                        suffixIcon: IconButton(
                          onPressed:
                              widget.viewModel.toggleConfirmPasswordVisibility,
                          icon: Icon(
                            state.isConfirmPasswordHidden
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                ),
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    localizeAuthMessage(context, state.errorMessage!),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 26),
                SizedBox(
                  height: 46,
                  child: FilledButton(
                    onPressed: state.isLoading ? null : _register,
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
                            context.l10n.authCreateAccount,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  context.l10n.registerVerificationNotice,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
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
      hintStyle: const TextStyle(color: AppColors.textMuted),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }
}
