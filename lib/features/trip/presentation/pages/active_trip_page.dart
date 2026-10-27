import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/trip_model.dart';
import '../../data/services/trip_service.dart';
import 'station_qr_scan_page.dart';

class ActiveTripPage extends StatefulWidget {
  final TripModel trip;

  const ActiveTripPage({super.key, required this.trip});

  @override
  State<ActiveTripPage> createState() => _ActiveTripPageState();
}

class _ActiveTripPageState extends State<ActiveTripPage> {
  final TripService _tripService = TripService();
  late Timer _timer;
  Duration _duration = Duration.zero;
  bool _isEnding = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _duration = DateTime.now().difference(widget.trip.startTime);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _duration = DateTime.now().difference(widget.trip.startTime);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = d.inHours.toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Future<void> _handleEndTrip() async {
    // 1. Durak QR Kodunu Okut
    final stationQr = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const StationQrScanPage()),
    );

    if (stationQr == null) return;

    setState(() => _isEnding = true);

    try {
      // 2. Durağı Doğrula
      final station = await _tripService.validateEndStation(stationQr);

      // 3. Kanıt Fotoğrafı Çek (Base64 Dönüşümü İçin Optimize Edildi)
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 30,
      );

      if (photo == null) {
        setState(() => _isEnding = false);
        return;
      }

      // 4. Firestore'a Kaydet ve Sürüşü Kapat
      await _tripService.completeTrip(
        activeTrip: widget.trip,
        endStation: station,
        photoFile: File(photo.path),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sürüş Tamamlandı! Bisiklet ${station.name} durağına kilitlendi.'),
            backgroundColor: const Color(0xFF00875A),
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
    } finally {
      if (mounted) setState(() => _isEnding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text('Aktif Sürüş', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2A33))),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Spacer(),

            // Bisiklet Görsel Alanı
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00875A).withOpacity(0.3), width: 3),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 8))],
              ),
              child: const Icon(Icons.directions_bike_rounded, size: 70, color: Color(0xFF00875A)),
            ),

            const SizedBox(height: 24),

            // Bisiklet Numarası ve Başlangıç Durağı
            Text(
              'Bisiklet ${widget.trip.bikeQrCode.replaceAll('HKU_BIKE_', '#')}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F2A33)),
            ),
            const SizedBox(height: 4),
            Text(
              'Başlangıç: ${widget.trip.startStationName}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),

            const SizedBox(height: 28),

            // Canlı SaySayaç
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Text(
                    _formatDuration(_duration),
                    style: const TextStyle(fontSize: 46, fontWeight: FontWeight.w900, color: Color(0xFF0F2A33), letterSpacing: 2),
                  ),
                  const SizedBox(height: 4),
                  const Text('Geçen Sürüş Süresi', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),

            const Spacer(),

            // Sürüşü Bitir Butonu
            ElevatedButton(
              onPressed: _isEnding ? null : _handleEndTrip,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                elevation: 0,
              ),
              child: _isEnding
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.stop_rounded, size: 24),
                  SizedBox(width: 8),
                  Text('Sürüşü Bitir (Durak QR + Fotoğraf)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}