import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardian_plus_app/core/service_locator.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/auth/domain/otp_purpose.dart';
import 'package:guardian_plus_app/features/auth/presentation/otp/otp_verification_state.dart';
import 'package:guardian_plus_app/features/auth/presentation/otp/otp_verification_view_model.dart';
import 'package:guardian_plus_app/features/profile/presentation/start/session_start_page.dart';
import 'package:guardian_plus_app/l10n/l10n.dart';
import 'package:guardian_plus_app/features/auth/presentation/auth_message_localizer.dart';

class OtpVerificationPage extends StatefulWidget {
  final String userAccountId;
  final String email;
  final OtpPurpose purpose;

  const OtpVerificationPage({
    super.key,
    required this.userAccountId,
    required this.email,
    required this.purpose,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  late final OtpVerificationViewModel viewModel;

  final TextEditingController codeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    viewModel = getIt<OtpVerificationViewModel>();
  }

  @override
  void dispose() {
    codeController.dispose();
    viewModel.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final verified = await viewModel.verify(
      userAccountId: widget.userAccountId,
      purpose: widget.purpose,
    );

    if (!mounted || !verified) {
      codeController.clear();
      return;
    }

    if (widget.purpose == OtpPurpose.login) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SessionStartPage()),
        (_) => false,
      );

      return;
    }

    // Para EMAIL_VERIFICATION:
    // devolvemos true a RegisterPage.
    Navigator.of(context).pop(true);
  }

  Future<void> _resend() async {
    await viewModel.resend(
      userAccountId: widget.userAccountId,
      purpose: widget.purpose,
    );

    codeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final state = viewModel.state;

        final actionMessage = state.actionMessage;

        if (actionMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }

            ScaffoldMessenger.of(this.context)
                .showSnackBar(SnackBar(content: Text(actionMessage)));

            viewModel.clearActionMessage();
          });
        }

        final isEmailVerification =
            widget.purpose == OtpPurpose.emailVerification;

        return Scaffold(
          backgroundColor: AppColors.sheet,
          appBar: AppBar(
            backgroundColor: AppColors.sheet,
            title: Text(
              isEmailVerification
                  ? context.l10n.otpVerifyEmailTitle
                  : context.l10n.otpVerificationTitle,
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 28),

                const Icon(
                  Icons.mark_email_read_outlined,
                  size: 56,
                  color: AppColors.primary,
                ),

                const SizedBox(height: 24),

                Text(
                  isEmailVerification
                      ? context.l10n.otpConfirmEmail
                      : context.l10n.otpCheckEmail,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  context.l10n.otpCodeSentPrefix + ' ' + widget.email + '.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textMuted),
                ),

                const SizedBox(height: 32),

                TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: authCodeLength,
                  autofocus: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(authCodeLength),
                  ],
                  onChanged: viewModel.onCodeChanged,
                  onSubmitted: (_) {
                    if (state.isComplete && !state.isLoading) {
                      _verify();
                    }
                  },
                  style: const TextStyle(
                    fontSize: 28,
                    letterSpacing: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '000000',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),

                if (state.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    localizeAuthMessage(context, state.errorMessage!),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                SizedBox(
                  height: 46,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: state.isLoading || !state.isComplete
                        ? null
                        : _verify,
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
                            isEmailVerification
                                ? context.l10n.otpVerifyEmail
                                : context.l10n.otpVerifyCode,
                          ),
                  ),
                ),

                const SizedBox(height: 22),

                TextButton(
                  onPressed: state.canResend ? _resend : null,
                  child: state.isResending
                      ? Text(context.l10n.otpResending)
                      : state.canResend
                      ? Text(context.l10n.otpResendCode)
                      : Text(
                          context.l10n.otpResendIn +
                              ' ' +
                              state.resendCountdown.toString(),
                        ),
                ),

                if (isEmailVerification) ...[
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.otpMustVerifyBeforeLogin,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
