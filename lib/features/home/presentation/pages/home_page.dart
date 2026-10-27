import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/station_model.dart';
import '../../data/models/bike_model.dart';
import '../../data/services/home_service.dart';
import '../../../trip/data/models/trip_model.dart';
import '../../../trip/data/services/trip_service.dart';
import '../../../trip/presentation/pages/active_trip_page.dart';

class _C {
  static const primary = Color(0xFF00875A);
  static const primaryDark = Color(0xFF005236);
  static const ink = Color(0xFF0F2A33);
  static const muted = Color(0xFF64748B);
  static const bg = Color(0xFFF8FAFB);
  static const cardBg = Colors.white;
  static const line = Color(0xFFE2E8F0);
  static const chipBg = Color(0xFFF1F5F9);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeService _homeService = HomeService();
  final TripService _tripService = TripService();
  String? _selectedStationId;

  @override
  void initState() {
    super.initState();
    _homeService.seedInitialCampusData();
  }

  IconData _getStationIcon(String code) {
    switch (code) {
      case 'MÜH':
        return Icons.engineering_rounded;
      case 'SĞL':
        return Icons.medical_services_rounded;
      case 'EĞT':
        return Icons.school_rounded;
      case 'HUK':
        return Icons.gavel_rounded;
      case 'SPOR':
        return Icons.sports_golf_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? '';

    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          // Firestore'daki kayıtlı kullanıcı dokümanını dinle
          stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
          builder: (context, userSnap) {
            final userData = userSnap.data?.data() as Map<String, dynamic>?;

            // Sırasıyla: Firestore 'name' -> Firebase Auth 'displayName' -> Varsayılan 'HKÜ Öğrencisi'
            final String displayName = userData?['name'] ?? user?.displayName ?? 'HKÜ Öğrencisi';

            return StreamBuilder<TripModel?>(
              stream: _tripService.getActiveTripStream(userId),
              builder: (context, activeTripSnap) {
                final activeTrip = activeTripSnap.data;

                return StreamBuilder<List<StationModel>>(
                  stream: _homeService.getStationsStream(),
                  builder: (context, stationSnap) {
                    if (stationSnap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: _C.primary));
                    }

                    final stations = stationSnap.data ?? [];

                    return StreamBuilder<List<BikeModel>>(
                      stream: _homeService.getAllBikesStream(),
                      builder: (context, bikeSnap) {
                        final allBikes = bikeSnap.data ?? [];

                        final Map<String, int> stationBikeCounts = {};
                        for (var station in stations) {
                          final availableCount = allBikes
                              .where((b) => b.stationId == station.id && b.status == 'available')
                              .length;
                          stationBikeCounts[station.id] = availableCount;
                        }

                        final totalCampusAvailable = allBikes.where((b) => b.status == 'available').length;

                        return Column(
                          children: [
                            // 1. Kayıtlı İsimle Header
                            _buildHeader(displayName, totalCampusAvailable, allBikes.length),

                            Expanded(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 12),

                                    // 2. Devam Eden Sürüş Varsa Aktif Sürüş Banner'ı
                                    if (activeTrip != null) ...[
                                      _buildActiveTripBanner(activeTrip),
                                      const SizedBox(height: 16),
                                    ],

                                    // Harita Başlığı
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(Icons.map_outlined, color: _C.primary, size: 20),
                                              SizedBox(width: 8),
                                              Text('HKÜ Şematik Kampüs Haritası', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: _C.ink)),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(color: _C.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                            child: const Text('Canlı 🟢', style: TextStyle(fontSize: 11, color: _C.primary, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // 3. İnteraktif Harita Simülasyonu
                                    _buildSchematicMapSimulation(stations, stationBikeCounts),

                                    const SizedBox(height: 20),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Fakülte Park Stokları', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _C.ink)),
                                          Text('${stations.length} Durak Aktif', style: const TextStyle(fontSize: 12, color: _C.muted, fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // 4. Durak Kartları Listesi
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      itemCount: stations.length,
                                      itemBuilder: (context, index) {
                                        final station = stations[index];
                                        final availableBikes = stationBikeCounts[station.id] ?? 0;
                                        final isSelected = station.id == _selectedStationId;

                                        return _buildStationCard(station, availableBikes, isSelected);
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Kullanıcı Bilgisi ve Genel Özet Başlığı
  Widget _buildHeader(String displayName, int availableCount, int totalCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _C.line)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: _C.primary.withOpacity(0.12),
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'H',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: _C.primary, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Merhaba, $displayName', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _C.ink)),
                          const SizedBox(width: 4),
                          const Text('👋', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                      const Text('HKÜ Kampüs İçi Akıllı Bisiklet', style: TextStyle(fontSize: 11, color: _C.muted)),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Arıza bildirimi modülü bir sonraki adımda açılacak.')),
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(color: _C.chipBg, shape: BoxShape.circle),
                      child: const Icon(Icons.build_outlined, color: Colors.orangeAccent, size: 20),
                    ),
                    tooltip: 'Arıza Bildir',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_C.primaryDark, _C.primary]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), shape: BoxShape.circle),
                      child: const Icon(Icons.directions_bike_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kampüsteki Bisiklet Durumu', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        Text('$availableCount / $totalCount Bisiklet Müsait', style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                    children: [
                      Icon(Icons.wb_sunny_rounded, color: Colors.orange, size: 14),
                      SizedBox(width: 4),
                      Text('Sürüşe Uygun', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _C.ink)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Devam Eden Aktif Sürüş Banner Kartı
  Widget _buildActiveTripBanner(TripModel trip) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.ink,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: _C.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pedal_bike_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Text('SÜRÜŞÜNÜZ DEVAM EDİYOR', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Bisiklet ${trip.bikeQrCode.replaceAll('HKU_BIKE_', '#')}',
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Başlangıç: ${trip.startStationName}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ActiveTripPage(trip: trip)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              elevation: 0,
            ),
            child: const Row(
              children: [
                Text('Yönet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchematicMapSimulation(List<StationModel> stations, Map<String, int> bikeCounts) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xFFEDF4F1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _C.primary.withOpacity(0.3), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(60),
          minScale: 0.8,
          maxScale: 2.5,
          child: SizedBox(
            width: 500,
            height: 340,
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: CampusRoadsPainter())),
                ...stations.map((station) {
                  final availableBikes = bikeCounts[station.id] ?? 0;
                  final isSelected = station.id == _selectedStationId;

                  Color statusColor = _C.primary;
                  if (availableBikes == 0) statusColor = Colors.redAccent;
                  else if (availableBikes <= 2) statusColor = Colors.orange;

                  return Positioned(
                    left: station.mapX,
                    top: station.mapY,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedStationId = isSelected ? null : station.id),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isSelected ? _C.ink : statusColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.directions_bike_rounded, color: Colors.white, size: 11),
                                const SizedBox(width: 4),
                                Text('$availableBikes Müsait', style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 3),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: isSelected ? 46 : 40,
                            height: isSelected ? 46 : 40,
                            decoration: BoxDecoration(
                              color: isSelected ? _C.primary : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: isSelected ? Colors.white : statusColor, width: 2.5),
                            ),
                            child: Icon(_getStationIcon(station.code), color: isSelected ? Colors.white : _C.ink, size: 20),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(6)),
                            child: Text(station.code, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: _C.ink)),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStationCard(StationModel station, int availableBikes, bool isSelected) {
    final double occupancyRate = station.capacity > 0 ? (availableBikes / station.capacity) : 0;
    Color statusColor = _C.primary;
    if (availableBikes == 0) statusColor = Colors.redAccent;
    else if (availableBikes <= 2) statusColor = Colors.orange;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected ? _C.primary.withOpacity(0.05) : _C.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isSelected ? _C.primary : _C.line, width: isSelected ? 2 : 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(_getStationIcon(station.code), color: statusColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(station.name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: _C.ink)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: occupancyRate,
                          backgroundColor: _C.chipBg,
                          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('$availableBikes/${station.capacity} Müsait', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CampusRoadsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dashLinePaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(70, 80)
      ..lineTo(270, 60)
      ..lineTo(360, 200)
      ..lineTo(250, 170)
      ..lineTo(120, 240)
      ..lineTo(70, 80)
      ..moveTo(270, 60)
      ..lineTo(250, 170);

    canvas.drawPath(path, roadPaint);
    canvas.drawPath(path, dashLinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}