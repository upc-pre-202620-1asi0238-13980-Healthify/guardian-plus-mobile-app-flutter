import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/service_locator.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/auth/presentation/login_viewmodel.dart';
import 'package:guardian_plus_app/features/auth/presentation/otp/otp_verification_page.dart';
import 'package:guardian_plus_app/features/auth/presentation/register/register_page.dart';
import 'package:guardian_plus_app/features/auth/presentation/register/register_viewmodel.dart';
import 'package:guardian_plus_app/l10n/l10n.dart';
import 'package:guardian_plus_app/features/auth/presentation/auth_message_localizer.dart';

class LoginPage extends StatelessWidget {
  final LoginViewmodel viewModel;

  const LoginPage({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hero,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Hero()),
          SliverFillRemaining(
            hasScrollBody: false,
            child: _LoginSheet(viewModel: viewModel),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 12,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(38),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.authHealthPlatform,
                      style: TextStyle(
                        fontFamily: AppFonts.mono,
                        fontFamilyFallback: AppFonts.monoFallback,
                        fontSize: 9,
                        letterSpacing: 2.5,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      'Guardian+',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 36),
            Text(
              context.l10n.authConnectedCare,
              style: TextStyle(
                fontSize: 36,
                height: 1.1,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.authMonitoringSubtitle,
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 32),
            Row(
              spacing: 24,
              children: [
                _stat('24/7', context.l10n.authMonitoringStat),
                _stat('5s', context.l10n.authUpdateStat),
                _stat('99.8%', context.l10n.authAvailabilityStat),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: AppFonts.mono,
            fontFamilyFallback: AppFonts.monoFallback,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppFonts.mono,
            fontFamilyFallback: AppFonts.monoFallback,
            fontSize: 10,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _LoginSheet extends StatefulWidget {
  const _LoginSheet({required this.viewModel});

  final LoginViewmodel viewModel;

  @override
  State<_LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<_LoginSheet> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  static const TextStyle _monoMuted = TextStyle(
    fontFamily: AppFonts.mono,
    fontFamilyFallback: AppFonts.monoFallback,
    fontSize: 12,
    color: AppColors.textMuted,
  );

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final navigation = await widget.viewModel.login(
      email: email.text,
      password: password.text,
    );

    if (!mounted || navigation == null) {
      return;
    }

    password.clear();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpVerificationPage(
          userAccountId: navigation.userAccountId,
          email: navigation.email,
          purpose: navigation.purpose,
        ),
      ),
    );
  }

  Future<void> _openRegister() async {
    final verified = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RegisterPage(viewModel: getIt<RegisterViewmodel>()),
      ),
    );

    if (!mounted || verified != true) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.authAccountVerified)));
  }

  void _googleSignIn() {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.authGoogleSoon)));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        final state = widget.viewModel.state;

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          decoration: const BoxDecoration(
            color: AppColors.sheet,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 28,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.authLogin,
                style: TextStyle(fontSize: 15, color: AppColors.textMuted),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.authLoginSubtitle,
                style: TextStyle(fontSize: 15, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),

              _label(context.l10n.authEmail.toUpperCase(), letterSpacing: 1.5),

              const SizedBox(height: 12),

              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(context.l10n.authEmailHint),
              ),

              const SizedBox(height: 16),

              _label(
                context.l10n.authPassword.toUpperCase(),
                letterSpacing: 1.5,
              ),

              const SizedBox(height: 12),

              TextField(
                controller: password,
                obscureText: state.isPasswordHidden,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (!state.isLoading) {
                    _login();
                  }
                },
                decoration: _inputDecoration(context.l10n.authPasswordHint)
                    .copyWith(
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

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    // Password reset se conectará
                    // en su bloque correspondiente.
                  },
                  child: Text(
                    context.l10n.authForgotPassword,
                    style: _monoMuted,
                  ),
                ),
              ),

              if (state.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  localizeAuthMessage(context, state.errorMessage!),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 40,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: state.isLoading ? null : _login,
                  child: state.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 8,
                          children: [
                            Icon(Icons.verified_user_outlined, size: 16),
                            Text(
                              context.l10n.authSecureLogin,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                spacing: 12,
                children: [
                  Expanded(child: Divider(color: AppColors.border)),
                  Text(context.l10n.authContinueWith, style: _monoMuted),
                  Expanded(child: Divider(color: AppColors.border)),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.textDark,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _googleSignIn,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 10,
                    children: [
                      _GoogleLogo(size: 15),
                      Text(
                        context.l10n.authContinueWithGoogle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Center(
                child: GestureDetector(
                  onTap: _openRegister,
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                      children: [
                        TextSpan(text: context.l10n.authNoAccount + ' '),
                        TextSpan(
                          text: context.l10n.authCreateAccount,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  context.l10n.authTermsNotice,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.mono,
                    fontFamilyFallback: AppFonts.monoFallback,
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _label(String text, {double letterSpacing = 0.5}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: letterSpacing,
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
      hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _GoogleLogoPainter());
  }
}

class _GoogleLogoPainter extends CustomPainter {
  static const double _deg = 3.1415926535 / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final double stroke = size.width * 0.22;

    final Rect rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );

    Paint arc(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    canvas.drawArc(
      rect,
      -140 * _deg,
      100 * _deg,
      false,
      arc(const Color(0xFFEA4335)),
    );

    canvas.drawArc(
      rect,
      140 * _deg,
      80 * _deg,
      false,
      arc(const Color(0xFFFBBC05)),
    );

    canvas.drawArc(
      rect,
      45 * _deg,
      95 * _deg,
      false,
      arc(const Color(0xFF34A853)),
    );

    canvas.drawArc(rect, 0, 45 * _deg, false, arc(const Color(0xFF4285F4)));

    canvas.drawRect(
      Rect.fromLTRB(
        size.width / 2,
        size.height / 2 - stroke / 2,
        size.width,
        size.height / 2 + stroke / 2,
      ),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
