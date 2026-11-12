import 'package:flutter/material.dart';
import 'package:guardian_plus_app/core/theme.dart';
import 'package:guardian_plus_app/features/auth/presentation/login_viewmodel.dart';
import 'package:guardian_plus_app/features/main/main_page.dart';

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
                        child: _LoginSheet(viewModel: viewModel)
                    )
                ],
            )
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
                  child: const Icon(Icons.verified_user_outlined, color: Colors.white, size: 20),
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PLATAFORMA DE SALUD',
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 36),
            const Text(
              'Cuidado\nconectado.',
              style: TextStyle(
                fontSize: 36,
                height: 1.1,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Monitoreo en tiempo real para quienes importan',
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 32),
            Row(
              spacing: 24,
              children: [
                _stat('24/7', 'Monitoreo'),
                _stat('5s', 'Actualización'),
                _stat('99.8%', 'Disponibilidad'),
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
              const Text(
                'Iniciar Sesion',
                style: TextStyle(fontSize: 15, color: AppColors.textMuted),
              ),
              const SizedBox(height: 8),
              const Text(
                'Accede a tu cuenta de cuidador',
                style: TextStyle(fontSize: 15, color: AppColors.textMuted),
              ),
              const SizedBox(height: 4),
              _label('CORREO ELECTRONICO', letterSpacing: 1.5),
              const SizedBox(height: 12),
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('nombre@correo.com'),
              ),
              const SizedBox(height: 16),
              _label('Password'),
              const SizedBox(height: 12),
              TextField(
                controller: password,
                obscureText: state.isPasswordHidden,
                decoration: _inputDecoration('Ingrese u contrasena aca').copyWith(
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
                  onTap: () {},
                  child: const Text('¿Olvidaste tu contraseña?', style: _monoMuted),
                ),
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  state.errorMessage!,
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  // Until the sign-in talks to IAM, it goes straight to the app with the demo care context
                  onPressed: state.isLoading
                      ? null
                      : () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const MainPage()),
                          ),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 8,
                          children: [
                            Icon(Icons.verified_user_outlined, size: 16),
                            Text(
                              'Ingresar de forma segura',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              const Row(
                spacing: 12,
                children: [
                  Expanded(child: Divider(color: AppColors.border)),
                  Text('o continúa con', style: _monoMuted),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {},
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 10,
                    children: [
                      _GoogleLogo(size: 15),
                      Text(
                        'Continuar con Google',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap: () {},
                  child: const Text.rich(
                    TextSpan(
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      children: [
                        TextSpan(text: '¿No tienes cuenta? '),
                        TextSpan(
                          text: 'Crear cuenta',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Al ingresar, aceptas los Términos de uso y la Política de privacidad',
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

    canvas.drawArc(rect, -140 * _deg, 100 * _deg, false, arc(const Color(0xFFEA4335)));
    canvas.drawArc(rect, 140 * _deg, 80 * _deg, false, arc(const Color(0xFFFBBC05)));
    canvas.drawArc(rect, 45 * _deg, 95 * _deg, false, arc(const Color(0xFF34A853)));
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
