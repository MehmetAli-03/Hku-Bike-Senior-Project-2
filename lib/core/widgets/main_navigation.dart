import 'package:flutter/material.dart';
import 'package:hku_bike/features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profil_page.dart';
import 'bottom_nav_bar.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  static const Color _primary = Color(0xFF00875A);

  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const Center(child: Text('🚴 Aktif Sürüş')),
    const SizedBox(), // QR FAB için boş tutucu sayfa (Index 2)
    const Center(child: Text('📜 Geçmiş Yolculuklar')),
    const ProfilPage(),
  ];

  void _openQrScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Container(
        height: 300,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.qr_code_scanner_rounded, size: 70, color: _primary),
            const SizedBox(height: 16),
            const Text(
              'Bisiklet QR Kodunu Taratın',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gidon veya kilit üzerindeki QR kodu hizalayın.',
              style: TextStyle(color: Colors.grey),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // trip_scan modülü buraya bağlanacak
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text('Kamerayı Başlat', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: SizedBox(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          onPressed: _openQrScanner,
          backgroundColor: _primary,
          elevation: 6,
          shape: const CircleBorder(),
          child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        onQrTap: _openQrScanner,
      ),
    );
  }
}