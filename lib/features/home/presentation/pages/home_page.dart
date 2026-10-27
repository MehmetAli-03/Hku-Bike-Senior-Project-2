import 'package:flutter/material.dart';

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

// Şematik İletişim Veri Modeli
class FacultyStation {
  final String id;
  final String name;
  final String code;
  final int availableBikes;
  final int totalCapacity;
  final Offset positionOnMap; // Simülasyondaki x, y koordinatı
  final IconData icon;

  FacultyStation({
    required this.id,
    required this.name,
    required this.code,
    required this.availableBikes,
    required this.totalCapacity,
    required this.positionOnMap,
    required this.icon,
  });

  double get occupancyRate => availableBikes / totalCapacity;

  Color get statusColor {
    if (availableBikes == 0) return Colors.redAccent;
    if (occupancyRate <= 0.3) return Colors.orange;
    return _C.primary;
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedStationId;

  // HKÜ Kampüs Şematik İstasyon Verileri
  final List<FacultyStation> _stations = [
    FacultyStation(
      id: 'eng',
      name: 'Mühendislik Fakültesi',
      code: 'MÜH',
      availableBikes: 7,
      totalCapacity: 12,
      positionOnMap: const Offset(80, 70),
      icon: Icons.engineering_rounded,
    ),
    FacultyStation(
      id: 'iibf',
      name: 'İktisadi ve İdari Bilimler',
      code: 'İİBF',
      availableBikes: 4,
      totalCapacity: 10,
      positionOnMap: const Offset(260, 90),
      icon: Icons.account_balance_rounded,
    ),
    FacultyStation(
      id: 'law',
      name: 'Hukuk Fakültesi',
      code: 'HUK',
      availableBikes: 2,
      totalCapacity: 8,
      positionOnMap: const Offset(360, 220),
      icon: Icons.gavel_rounded,
    ),
    FacultyStation(
      id: 'ydyo',
      name: 'Yabancı Diller Yüksekokulu',
      code: 'YDYO',
      availableBikes: 9,
      totalCapacity: 15,
      positionOnMap: const Offset(120, 260),
      icon: Icons.translate_rounded,
    ),
    FacultyStation(
      id: 'lib',
      name: 'Merkez Kütüphane & Meydan',
      code: 'KÜT',
      availableBikes: 11,
      totalCapacity: 20,
      positionOnMap: const Offset(230, 200),
      icon: Icons.local_library_rounded,
    ),
  ];

  int get _totalAvailable => _stations.fold(0, (sum, item) => sum + item.availableBikes);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Üst Başlık ve Özet Bilgi Barı
            _buildHeader(),

            // 2. Ana Gövde (Kaydırılabilir İçerik)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Harita Simülasyon Alanı Başlığı
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.map_outlined, color: _C.primary, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Şematik Kampüs Haritası',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _C.ink),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _C.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Kaydırılabilir 🔍',
                              style: TextStyle(fontSize: 11, color: _C.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 3. İNTERAKTİF ŞEMATİK KAMPÜS SİMÜLASYONU
                    _buildSchematicMapSimulation(),

                    const SizedBox(height: 20),

                    // 4. Fakülte Park Stokları Başlık
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Fakülte Park Stokları',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _C.ink),
                          ),
                          Text(
                            '${_stations.length} İstasyon Aktif',
                            style: const TextStyle(fontSize: 12, color: _C.muted, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 5. İstasyon Listesi
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _stations.length,
                      itemBuilder: (context, index) {
                        final station = _stations[index];
                        final isSelected = station.id == _selectedStationId;

                        return _buildStationCard(station, isSelected);
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header Widget
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
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
                  Image.asset(
                    'assets/images/hku_logo.png',
                    height: 38,
                    errorBuilder: (_, __, ___) => const Icon(Icons.pedal_bike, color: _C.primary, size: 32),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'HKÜ BikeShare',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _C.ink),
                      ),
                      Text(
                        'Kampüs İçi Bisiklet Takibi',
                        style: TextStyle(fontSize: 11, color: _C.muted),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _C.chipBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_none_rounded, color: _C.ink, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Canlı Özet İstatistik Kartı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_C.primaryDark, _C.primary],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.directions_bike, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kampüsteki Müsait Bisikletler', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        Text(
                          '$_totalAvailable Adet Müsait',
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
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

  // İnteraktif Harita Simülasyonu
  Widget _buildSchematicMapSimulation() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xFFEDF4F1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _C.primary.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(60),
          minScale: 0.8,
          maxScale: 2.5,
          child: SizedBox(
            width: 500,
            height: 360,
            child: Stack(
              children: [
                // Vektörel Kampüs Yolları Painter
                Positioned.fill(
                  child: CustomPaint(
                    painter: CampusRoadsPainter(),
                  ),
                ),

                // Fakülte Binaları & Stok Rozetleri
                ..._stations.map((station) {
                  final isSelected = station.id == _selectedStationId;

                  return Positioned(
                    left: station.positionOnMap.dx,
                    top: station.positionOnMap.dy,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedStationId = isSelected ? null : station.id;
                        });
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Stok Balonu
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? _C.ink : station.statusColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.directions_bike_rounded, color: Colors.white, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  '${station.availableBikes} Müsait',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Bina Simgesi Kartı
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: isSelected ? 48 : 42,
                            height: isSelected ? 48 : 42,
                            decoration: BoxDecoration(
                              color: isSelected ? _C.primary : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : station.statusColor,
                                width: isSelected ? 3 : 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Icon(
                              station.icon,
                              color: isSelected ? Colors.white : _C.ink,
                              size: isSelected ? 24 : 20,
                            ),
                          ),

                          const SizedBox(height: 2),

                          // Kod Etiketi
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              station.code,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: _C.ink,
                              ),
                            ),
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

  // İstasyon Liste Kartı
  Widget _buildStationCard(FacultyStation station, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected ? _C.primary.withOpacity(0.05) : _C.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? _C.primary : _C.line,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: station.statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(station.icon, color: station.statusColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _C.ink),
                ),
                const SizedBox(height: 4),
                // İlerleme Çubuğu (Doluluk)
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: station.occupancyRate,
                          backgroundColor: _C.chipBg,
                          valueColor: AlwaysStoppedAnimation<Color>(station.statusColor),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${station.availableBikes}/${station.totalCapacity}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: station.statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedStationId = station.id;
              });
            },
            icon: Icon(
              isSelected ? Icons.location_on : Icons.location_on_outlined,
              color: isSelected ? _C.primary : _C.muted,
            ),
          ),
        ],
      ),
    );
  }
}

// Kampüs Vektör Yolları Painter
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

    final path = Path();

    // Kampüs İç Yolları Çizimi
    path.moveTo(60, 90);
    path.lineTo(280, 110);
    path.lineTo(380, 240);
    path.lineTo(250, 220);
    path.lineTo(140, 280);
    path.lineTo(60, 90);

    // Kütüphane Ara Yolu
    path.moveTo(280, 110);
    path.lineTo(250, 220);

    canvas.drawPath(path, roadPaint);
    canvas.drawPath(path, dashLinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}