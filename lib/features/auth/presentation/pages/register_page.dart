import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const Color _primary = Color(0xFF00875A);
  static const Color _ink = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _hint = Color(0xFF94A3B8);
  static const Color _fieldBg = Color(0xFFF8FAFC);
  static const Color _border = Color(0xFFE2E8F0);

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();
  final _schoolNoController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authService = AuthService();
  bool _termsAccepted = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _schoolNoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lütfen kullanım koşullarını kabul edin.'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        schoolNo: _schoolNoController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        department: _departmentController.text.trim(),
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _primary.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mark_email_read_outlined, color: _primary, size: 32),
            ),
            title: const Text(
              'Hesap Oluşturuldu',
              style: TextStyle(fontWeight: FontWeight.w800, color: _ink, fontSize: 18),
            ),
            content: Text(
              '${_emailController.text.trim()} adresine doğrulama bağlantısı gönderildi. Lütfen e-postanızı onaylayın.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, fontSize: 13.5, height: 1.4),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Giriş Ekranına Dön',
                  style: TextStyle(color: _primary, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', '').replaceAll('FormatException: ', ''),
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              child: CustomPaint(
                size: Size(150, 150),
                painter: TopRightGreenCurvePainter(),
              ),
            ),
          ),

          // Sağ alt desen: ekran köşesine tam oturur, taşma yok
          const Positioned(
            bottom: 0,
            right: 0,
            child: IgnorePointer(
              child: CustomPaint(
                size: Size(190, 130),
                painter: BottomRightGreenWavePainter(),
              ),
            ),
          ),

          // Form içeriği
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(28, 4, 28, 12),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Üst bar: geri butonu + büyük logo
                        SizedBox(
                          height: 72,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Material(
                                  color: Colors.white,
                                  shape: const CircleBorder(side: BorderSide(color: _border)),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () => Navigator.pop(context),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(Icons.chevron_left_rounded, color: _ink, size: 24),
                                    ),
                                  ),
                                ),
                              ),
                              Image.asset(
                                'assets/images/hku_logo.png',
                                height: 64,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  'assets/images/hku-logo.png',
                                  height: 64,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'Hesap Oluştur',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _ink,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Hemen kayıt ol, bisikletlerini takip etmeye başla.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.5, color: _muted, height: 1.35),
                        ),

                        const SizedBox(height: 16),

                        _buildInputField(
                          controller: _fullNameController,
                          hintText: 'Ad Soyad',
                          icon: Icons.person_outline_rounded,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [AutofillHints.name],
                          validator: (v) =>
                          (v == null || v.trim().length < 3) ? 'Ad soyad giriniz.' : null,
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _emailController,
                          hintText: 'E-posta Adresi',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
                            return ok ? null : 'Geçerli bir e-posta giriniz.';
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _phoneController,
                          hintText: 'Telefon Numarası',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]'))],
                          validator: (v) {
                            final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                            return digits.length < 10 ? 'Geçerli bir telefon giriniz.' : null;
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _departmentController,
                          hintText: 'Bölüm (Örn: Yazılım Müh.)',
                          icon: Icons.account_balance_outlined,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Bölüm giriniz.' : null,
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _schoolNoController,
                          hintText: 'Öğrenci No (Opsiyonel)',
                          icon: Icons.school_outlined,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _passwordController,
                          hintText: 'Şifre (en az 6 karakter)',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.newPassword],
                          onSubmitted: (_) => _handleRegister(),
                          validator: (v) =>
                          (v == null || v.length < 6) ? 'Şifre en az 6 karakter olmalı.' : null,
                          suffixIcon: IconButton(
                            splashRadius: 20,
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: _hint,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),

                        const SizedBox(height: 14),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 22,
                              width: 22,
                              child: Checkbox(
                                value: _termsAccepted,
                                activeColor: _primary,
                                side: const BorderSide(color: _hint, width: 1.4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                onChanged: (val) => setState(() => _termsAccepted = val ?? false),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _termsAccepted = !_termsAccepted),
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(fontSize: 12, color: _muted, height: 1.4),
                                    children: [
                                      TextSpan(
                                        text: 'Kullanım Koşulları ',
                                        style: TextStyle(color: _primary, fontWeight: FontWeight.w700),
                                      ),
                                      TextSpan(text: 've '),
                                      TextSpan(
                                        text: 'Gizlilik Politikası',
                                        style: TextStyle(color: _primary, fontWeight: FontWeight.w700),
                                      ),
                                      TextSpan(text: '\'nı okudum ve kabul ediyorum.'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Kayıt ol butonu
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
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              disabledBackgroundColor: _primary.withAlpha(150),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 48),
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
                                  'Kayıt Ol',
                                  style: TextStyle(
                                    fontSize: 16,
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

                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Zaten hesabın var mı? ',
                              style: TextStyle(color: _muted, fontSize: 13.5),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                'Giriş Yap',
                                style: TextStyle(
                                  color: _primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Alt desenin altında içerik kalmasın diye boşluk
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
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
    TextCapitalization textCapitalization = TextCapitalization.none,
    Iterable<String>? autofillHints,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    void Function(String)? onSubmitted,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      validator: validator,
      onFieldSubmitted: onSubmitted,
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
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        errorStyle: const TextStyle(fontSize: 11.5, height: 1.2),
        enabledBorder: border(_border),
        focusedBorder: border(_primary, 1.6),
        errorBorder: border(Colors.red.shade300),
        focusedErrorBorder: border(Colors.red.shade400, 1.6),
        border: border(_border),
      ),
    );
  }
}

class TopRightGreenCurvePainter extends CustomPainter {
  const TopRightGreenCurvePainter();

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

    final path1 = Path()
      ..moveTo(w * 0.25, 0)
      ..quadraticBezierTo(w * 0.5, h * 0.65, w, h * 0.85)
      ..lineTo(w, 0)
      ..close();
    canvas.drawPath(path1, light);

    final path2 = Path()
      ..moveTo(w * 0.55, 0)
      ..quadraticBezierTo(w * 0.72, h * 0.4, w, h * 0.5)
      ..lineTo(w, 0)
      ..close();
    canvas.drawPath(path2, mid);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BottomRightGreenWavePainter extends CustomPainter {
  const BottomRightGreenWavePainter();

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

    // Arka katman: en geniş, en açık
    final path1 = Path()
      ..moveTo(0, h)
      ..cubicTo(w * 0.25, h * 0.55, w * 0.6, h * 0.75, w, h * 0.2)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(path1, layer1);

    // Orta katman
    final path2 = Path()
      ..moveTo(w * 0.3, h)
      ..cubicTo(w * 0.5, h * 0.7, w * 0.75, h * 0.85, w, h * 0.45)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(path2, layer2);

    // Ön katman: köşede koyu, ince
    final path3 = Path()
      ..moveTo(w * 0.6, h)
      ..cubicTo(w * 0.75, h * 0.85, w * 0.88, h * 0.9, w, h * 0.68)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(path3, layer3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}