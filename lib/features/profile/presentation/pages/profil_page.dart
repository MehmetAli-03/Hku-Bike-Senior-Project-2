import 'package:flutter/material.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../auth/data/models/user_model.dart';

class _C {
  static const primary = Color(0xFF00875A);
  static const primaryDark = Color(0xFF005236);
  static const avatar = Color(0xFF006B47);
  static const ink = Color(0xFF0F2A33);
  static const muted = Color(0xFF64748B);
  static const line = Color(0xFFE2E8F0);
  static const iconBg = Color(0xFFE6F4ED);
  static const bg = Color(0xFFF8FAFB);
}

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  // TODO: Gerçek sürüş verilerine bağla.
  static const _totalRides = '12';
  static const _totalDistance = '84 km';
  static const _co2Saved = '6.8 kg';
  static const _dailyAvg = '3';

  String _initials(String? name) {
    final parts = (name ?? '').trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  String? _department(UserModel? user) {
    try {
      final d = (user as dynamic).department as String?;
      return (d == null || d.trim().isEmpty) ? null : d.trim();
    } catch (_) {
      return null;
    }
  }

  Future<void> _confirmSignOut(BuildContext context, AuthService authService) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Çıkış Yap', style: TextStyle(fontWeight: FontWeight.w800, color: _C.ink)),
        content: const Text('Hesabınızdan çıkış yapmak istiyor musunuz?', style: TextStyle(color: _C.muted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç', style: TextStyle(color: _C.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Çıkış Yap', style: TextStyle(color: _C.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok == true) await authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firebaseUser = authService.currentUser;

    return Scaffold(
      backgroundColor: _C.bg,
      body: FutureBuilder<UserModel?>(
        future: firebaseUser != null ? authService.getUserProfile(firebaseUser.uid) : Future.value(null),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _C.primary));
          }

          final user = snapshot.data;
          final isStaff = user?.role == 'staff';
          final dept = _department(user);
          final schoolNo = (user?.schoolNo.isEmpty ?? true) ? '-' : user!.schoolNo;
          final phone = (user?.phoneNumber.isEmpty ?? true) ? '-' : user!.phoneNumber;

          return SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                const _ProfileHeader(),

                // Kullanıcı bilgisi
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 82,
                                height: 82,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(color: _C.avatar, shape: BoxShape.circle),
                                child: Text(
                                  _initials(user?.fullName),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: -2,
                                bottom: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: _C.avatar,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2.5),
                                  ),
                                  child: const Icon(Icons.photo_camera_rounded, color: Colors.white, size: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        user?.fullName ?? 'Kullanıcı',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: _C.ink,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.verified_rounded, color: _C.primary, size: 20),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isStaff ? 'Saha Personeli' : 'Öğrenci',
                                  style: const TextStyle(fontSize: 13.5, color: _C.muted),
                                ),
                                const SizedBox(height: 8),
                                _InfoLine(
                                  icon: Icons.school_outlined,
                                  text: 'HKÜ${dept != null ? ' - $dept' : ''}',
                                ),
                                const SizedBox(height: 6),
                                _InfoLine(
                                  icon: Icons.person_outline_rounded,
                                  text: 'Öğrenci No: $schoolNo',
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: _C.muted, size: 26),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1, color: _C.line),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.phone_rounded, size: 18, color: _C.primary),
                          const SizedBox(width: 8),
                          Text(phone, style: const TextStyle(fontSize: 13, color: _C.ink)),
                          const SizedBox(width: 20),
                          const Icon(Icons.mail_rounded, size: 18, color: _C.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              user?.email ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, color: _C.ink),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // İstatistik kartı
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: _Card(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.directions_bike_rounded, color: _C.primary, size: 24),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Bisiklet Kullanım İstatistikleri',
                                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: _C.ink),
                              ),
                            ),
                            InkWell(
                              onTap: () {},
                              child: const Row(
                                children: [
                                  Text('Detaylar', style: TextStyle(fontSize: 12, color: _C.primary, fontWeight: FontWeight.w600)),
                                  Icon(Icons.chevron_right_rounded, size: 18, color: _C.primary),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const IntrinsicHeight(
                          child: Row(
                            children: [
                              _Stat(icon: Icons.directions_bike_rounded, value: _totalRides, label: 'Toplam Kullanım'),
                              _StatDivider(),
                              _Stat(icon: Icons.add_location_alt_outlined, value: _totalDistance, label: 'Toplam Mesafe'),
                              _StatDivider(),
                              _Stat(icon: Icons.eco_outlined, value: _co2Saved, label: 'CO₂ Tasarrufu'),
                              _StatDivider(),
                              _Stat(icon: Icons.event_available_outlined, value: _dailyAvg, label: 'Günlük Ortalama'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Menü kartı
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: _Card(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Column(
                      children: [
                        _MenuTile(
                          icon: Icons.person_outline_rounded,
                          title: 'Kişisel Bilgiler',
                          subtitle: 'Ad, soyad, okul bilgileri, iletişim',
                          onTap: () {},
                        ),
                        const _MenuDivider(),
                        _MenuTile(
                          icon: Icons.shield_outlined,
                          title: 'Güvenlik',
                          subtitle: 'Şifre değiştir, hesap ayarları',
                          onTap: () {},
                        ),
                        const _MenuDivider(),
                        _MenuTile(
                          icon: Icons.article_outlined,
                          title: 'Kullanım Koşulları',
                          subtitle: 'Uygulama kullanım şartları',
                          onTap: () {},
                        ),
                        const _MenuDivider(),
                        _MenuTile(
                          icon: Icons.headset_mic_outlined,
                          title: 'Destek',
                          subtitle: 'Yardım ve sıkça sorulan sorular',
                          onTap: () {},
                        ),
                        const _MenuDivider(),
                        _MenuTile(
                          icon: Icons.warning_amber_rounded,
                          title: 'Şikayet / Geri Bildirim',
                          subtitle: 'Bize yazın',
                          onTap: () {},
                        ),
                        const _MenuDivider(),
                        _MenuTile(
                          icon: Icons.logout_rounded,
                          title: 'Çıkış Yap',
                          subtitle: 'Hesabınızdan güvenli şekilde çıkış yapın',
                          onTap: () => _confirmSignOut(context, authService),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Alt bilgi banner'ı
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE6F4ED), Color(0xFFF4FAF7)],
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_bike_rounded, color: _C.primary, size: 36),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bisikletini Koru, Doğayı Koru',
                                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: _C.ink),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Daha temiz bir kampüs, daha yeşil bir gelecek.',
                                style: TextStyle(fontSize: 11.5, color: _C.muted),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.eco_rounded, size: 46, color: _C.primary.withOpacity(0.7)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ───────────────────────── Header ─────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final width = MediaQuery.of(context).size.width;
    final height = top + 150;

    return ClipPath(
      clipper: _HeaderWaveClipper(),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [_C.primaryDark, _C.primary],
          ),
        ),
        child: Stack(
          children: [
            // Kampüs görseli (sağdan sola doğru solar)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: width * 0.68,
              child: ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.transparent, Colors.black],
                  stops: [0.0, 0.5],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  'assets/images/campus.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),

            // Orta kısımdaki koyu tepe
            Positioned(
              bottom: -8,
              left: width * 0.36,
              child: Container(
                width: width * 0.3,
                height: 46,
                decoration: BoxDecoration(
                  color: _C.primaryDark,
                  borderRadius: BorderRadius.vertical(top: Radius.elliptical(width * 0.15, 46)),
                ),
              ),
            ),

            // Logo
            Positioned(
              left: 22,
              top: top + 40,
              child: Image.asset(
                'assets/images/hku_logo.png',
                height: 46,
                color: Colors.white,
                colorBlendMode: BlendMode.srcIn,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Text(
                  'HASAN KALYONCU\nÜNİVERSİTESİ',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, height: 1.2),
                ),
              ),
            ),

            // Ayarlar
            Positioned(
              right: 16,
              top: top + 34,
              child: Material(
                color: Colors.white.withOpacity(0.18),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {},
                  child: const Padding(
                    padding: EdgeInsets.all(9),
                    child: Icon(Icons.settings_outlined, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..lineTo(0, h - 34)
      ..cubicTo(w * 0.3, h - 6, w * 0.5, h - 60, w * 0.72, h - 30)
      ..cubicTo(w * 0.85, h - 14, w * 0.93, h - 4, w, h - 6)
      ..lineTo(w, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ───────────────────────── Parçalar ─────────────────────────

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _C.ink),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.5, color: _C.ink),
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _Card({required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _Stat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _C.primary, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: _C.ink),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10.5, color: _C.muted, height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return const VerticalDivider(width: 1, thickness: 1, color: _C.line);
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(color: _C.iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: _C.primaryDark, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _C.ink),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: _C.muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _C.muted, size: 24),
          ],
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, indent: 68, endIndent: 10, color: _C.line);
  }
}