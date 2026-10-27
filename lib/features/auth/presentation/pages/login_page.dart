import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color _primary = Color(0xFF00875A);
  static const Color _ink = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _hint = Color(0xFF94A3B8);
  static const Color _fieldBg = Color(0xFFF8FAFC);
  static const Color _border = Color(0xFFE2E8F0);

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      _showSnack('Lütfen tüm alanları doldurun.', color: Colors.orange.shade700);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      if (mounted) {
        if (e.toString().contains('UNVERIFIED_EMAIL')) {
          _showUnverifiedEmailDialog();
        } else {
          _showSnack(
            e.toString().replaceAll('Exception: ', '').replaceAll('FormatException: ', ''),
            color: Colors.red.shade600,
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showSnack('Lütfen önce e-posta adresinizi yazın.');
      return;
    }
    try {
      await _authService.sendPasswordResetEmail(_emailController.text.trim());
      if (mounted) {
        _showSnack('Sıfırlama bağlantısı e-postanıza gönderildi.', color: _primary);
      }
    } catch (e) {
      if (mounted) {
        _showSnack(e.toString().replaceAll('Exception: ', ''), color: Colors.red.shade600);
      }
    }
  }

  void _showUnverifiedEmailDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: _primary.withAlpha(30), shape: BoxShape.circle),
          child: const Icon(Icons.mark_email_unread_outlined, color: _primary, size: 30),
        ),
        title: const Text(
          'E-Posta Doğrulanmadı',
          style: TextStyle(fontWeight: FontWeight.w800, color: _ink, fontSize: 18),
        ),
        content: const Text(
          'Lütfen e-postanıza gönderilen doğrulama bağlantısını onaylayın.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted, fontSize: 13.5, height: 1.4),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _authService.resendVerificationEmail(
                _emailController.text.trim(),
                _passwordController.text,
              );
            },
            child: const Text(
              'Tekrar Bağlantı Gönder',
              style: TextStyle(color: _primary, fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam', style: TextStyle(color: _muted)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Sağ üst desen
          const Positioned(
            top: 0,
            right: 0,
            child: IgnorePointer(
              child: CustomPaint(size: Size(150, 150), painter: LoginTopCurvePainter()),
            ),
          ),

          // Sağ alt desen
          const Positioned(
            bottom: 0,
            right: 0,
            child: IgnorePointer(
              child: CustomPaint(size: Size(190, 130), painter: LoginBottomWavePainter()),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 16),

                            // Logo
                            Center(
                              child: Image.asset(
                                'assets/images/hku-logo.png',
                                height: 68,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  'assets/images/hku_logo.png',
                                  height: 68,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            const SizedBox(height: 22),

                            // Başlıklar
                            const Text(
                              'Hoş Geldiniz',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: _ink,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Hesabınıza giriş yaparak bisikletlerinizi\nkolayca takip edebilirsiniz.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12.5, color: _muted, height: 1.4),
                            ),

                            const SizedBox(height: 24),

                            _buildInputField(
                              controller: _emailController,
                              hintText: 'E-posta Adresi',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                            ),
                            const SizedBox(height: 10),
                            _buildInputField(
                              controller: _passwordController,
                              hintText: 'Şifre',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              onSubmitted: (_) => _handleLogin(),
                              suffixIcon: IconButton(
                                splashRadius: 20,
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 19,
                                  color: _hint,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Beni hatırla & Şifremi unuttum
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => setState(() => _rememberMe = !_rememberMe),
                                  behavior: HitTestBehavior.opaque,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          activeColor: _primary,
                                          side: const BorderSide(color: _hint, width: 1.4),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          onChanged: (val) => setState(() => _rememberMe = val ?? true),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Beni hatırla',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: Color(0xFF334155),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _handleForgotPassword,
                                  child: const Text(
                                    'Şifremi Unuttum?',
                                    style: TextStyle(
                                      color: _primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Giriş yap
                            DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: _primary.withAlpha(70),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primary,
                                  disabledBackgroundColor: _primary.withAlpha(150),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                                )
                                    : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Giriş Yap',
                                      style: TextStyle(
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, size: 20),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // veya
                            const Row(
                              children: [
                                Expanded(child: Divider(color: _border, thickness: 1)),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'veya',
                                    style: TextStyle(color: _hint, fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Expanded(child: Divider(color: _border, thickness: 1)),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // Google
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                side: const BorderSide(color: _border, width: 1.2),
                                backgroundColor: Colors.white,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'G',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFEA4335),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Google ile Devam Et',
                                    style: TextStyle(
                                      color: Color(0xFF334155),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Kayıt ol
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Hesabın yok mu? ',
                                  style: TextStyle(color: _muted, fontSize: 13),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                                    );
                                  },
                                  child: const Text(
                                    'Kayıt Ol',
                                    style: TextStyle(
                                      color: _primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 36),

                            // Marka yazıları
                            const Text(
                              'Hasan Kalyoncu Üniversitesi',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11, color: _hint, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'BİSİKLET TAKİP UYGULAMASI',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8.5,
                                color: Color(0xFFB6C2D0),
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Iterable<String>? autofillHints,
    void Function(String)? onSubmitted,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onSubmitted: onSubmitted,
      cursorColor: _primary,
      style: const TextStyle(fontSize: 13.5, color: _ink, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: _hint, fontSize: 13, fontWeight: FontWeight.w400),
        prefixIcon: Icon(icon, color: _muted, size: 18),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: _fieldBg,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        enabledBorder: border(_border),
        focusedBorder: border(_primary, 1.6),
        border: border(_border),
      ),
    );
  }
}

class LoginTopCurvePainter extends CustomPainter {
  const LoginTopCurvePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final light = Paint()
      ..color = const Color(0xFF00875A).withAlpha(28)
      ..style = PaintingStyle.fill;
    final mid = Paint()
      ..color = const Color(0xFF00875A).withAlpha(55)
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path()
        ..moveTo(w * 0.25, 0)
        ..quadraticBezierTo(w * 0.5, h * 0.65, w, h * 0.85)
        ..lineTo(w, 0)
        ..close(),
      light,
    );

    canvas.drawPath(
      Path()
        ..moveTo(w * 0.55, 0)
        ..quadraticBezierTo(w * 0.72, h * 0.4, w, h * 0.5)
        ..lineTo(w, 0)
        ..close(),
      mid,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LoginBottomWavePainter extends CustomPainter {
  const LoginBottomWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final layer1 = Paint()
      ..color = const Color(0xFF00875A).withAlpha(30)
      ..style = PaintingStyle.fill;
    final layer2 = Paint()
      ..color = const Color(0xFF00875A).withAlpha(90)
      ..style = PaintingStyle.fill;
    final layer3 = Paint()
      ..color = const Color(0xFF00875A)
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path()
        ..moveTo(0, h)
        ..cubicTo(w * 0.25, h * 0.55, w * 0.6, h * 0.75, w, h * 0.2)
        ..lineTo(w, h)
        ..close(),
      layer1,
    );

    canvas.drawPath(
      Path()
        ..moveTo(w * 0.3, h)
        ..cubicTo(w * 0.5, h * 0.7, w * 0.75, h * 0.85, w, h * 0.45)
        ..lineTo(w, h)
        ..close(),
      layer2,
    );

    canvas.drawPath(
      Path()
        ..moveTo(w * 0.6, h)
        ..cubicTo(w * 0.75, h * 0.85, w * 0.88, h * 0.9, w, h * 0.68)
        ..lineTo(w, h)
        ..close(),
      layer3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}