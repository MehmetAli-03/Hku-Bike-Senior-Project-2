import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../home/data/models/bike_model.dart';
import '../../../home/data/services/home_service.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final MobileScannerController _controller = MobileScannerController();
  final HomeService _homeService = HomeService();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
        setState(() => _isProcessing = true);
        _controller.stop();

        final scannedText = barcode.rawValue!.trim();
        final bike = await _homeService.getBikeByQrCode(scannedText);

        if (!mounted) return;

        if (bike != null) {
          _showBikePreviewSheet(bike);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Geçersiz Bisiklet QR Kodu! Lütfen bisiklet üzerindeki QR kodu okutun.'),
              backgroundColor: Colors.red,
            ),
          );
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            setState(() => _isProcessing = false);
            _controller.start();
          }
        }
        break;
      }
    }
  }

  void _showBikePreviewSheet(BikeModel bike) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00875A).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.directions_bike_rounded, size: 48, color: Color(0xFF00875A)),
              ),
              const SizedBox(height: 14),
              Text(
                'Bisiklet ${bike.qrCode.replaceAll('HKU_BIKE_', '#')}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F2A33)),
              ),
              const SizedBox(height: 4),
              Text(
                'Durum: ${bike.status == 'available' ? 'Sürüşe Uygun 🟢' : 'Kullanımda 🔴'}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.battery_charging_full_rounded, color: Color(0xFF00875A), size: 20),
                    const SizedBox(width: 8),
                    Text('Batarya Seviyesi: %${bike.batteryLevel}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F2A33))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: bike.status == 'available'
                    ? () {
                  Navigator.pop(bottomSheetContext);
                  Navigator.pop(context, bike.qrCode);
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00875A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Sürüşü Başlat 🚀', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    ).then((_) {
      if (mounted && _isProcessing) {
        setState(() => _isProcessing = false);
        _controller.start();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Bisiklet QR Kodunu Taratın', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00875A), width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Gidon veya kilit üzerindeki bisiklet QR kodunu yeşil çerçeveye hizalayın.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 12.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}