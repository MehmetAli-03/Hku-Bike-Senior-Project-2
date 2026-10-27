import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profil_page.dart';
import '../../features/trip/data/models/trip_model.dart';
import '../../features/trip/data/services/trip_service.dart';
import '../../features/trip/presentation/pages/active_trip_page.dart';
import '../../features/trip/presentation/pages/qr_scan_page.dart';
import '../../features/trip/presentation/pages/trip_history_page.dart';
import 'bottom_nav_bar.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  static const Color _primary = Color(0xFF00875A);
  int _currentIndex = 0;

  final TripService _tripService = TripService();

  Future<void> _startNewTripByQr() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // Kamera ile QR Okutma Ekranını Aç
    final scannedQr = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );

    if (scannedQr == null || scannedQr.isEmpty) return;

    try {
      await _tripService.startTrip(userId: userId, bikeQrCode: scannedQr);
      if (mounted) {
        setState(() {
          _currentIndex = 1; // Sürüş başlayınca "Aktif Sürüş" sekmesine geç
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sürüş Başlatıldı! İyi yolculuklar 🚴'),
            backgroundColor: _primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<TripModel?>(
      stream: _tripService.getActiveTripStream(userId),
      builder: (context, snapshot) {
        final activeTrip = snapshot.data;

        final List<Widget> pages = [
          const HomePage(),
          activeTrip != null
              ? ActiveTripPage(trip: activeTrip)
              : const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_bike_outlined, size: 64, color: Color(0xFF94A3B8)),
                SizedBox(height: 12),
                Text(
                  'Aktif Sürüşünüz Bulunmuyor',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F2A33)),
                ),
                SizedBox(height: 6),
                Text(
                  'QR butonuna basarak bisiklet kiralayabilirsiniz.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const SizedBox(), // QR FAB için boş tutucu (Index 2)
          const TripHistoryPage(),
          const ProfilPage(),
        ];

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
          floatingActionButton: SizedBox(
            width: 64,
            height: 64,
            child: FloatingActionButton(
              onPressed: activeTrip != null
                  ? () => setState(() => _currentIndex = 1)
                  : _startNewTripByQr,
              backgroundColor: _primary,
              elevation: 6,
              shape: const CircleBorder(),
              child: Icon(
                activeTrip != null ? Icons.directions_bike_rounded : Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            onQrTap: activeTrip != null
                ? () => setState(() => _currentIndex = 1)
                : _startNewTripByQr,
          ),
        );
      },
    );
  }
}