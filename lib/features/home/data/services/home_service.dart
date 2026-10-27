import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/station_model.dart';
import '../models/bike_model.dart';

class HomeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Canlı Duraklar Stream'i
  Stream<List<StationModel>> getStationsStream() {
    return _db.collection('stations').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => StationModel.fromFirestore(doc)).toList();
    });
  }

  // Canlı Bisikletler Stream'i
  Stream<List<BikeModel>> getAllBikesStream() {
    return _db.collection('bikes').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => BikeModel.fromFirestore(doc)).toList();
    });
  }

  // QR Kod ile Bisiklet Sorgulama (Eksik Metod)
  Future<BikeModel?> getBikeByQrCode(String qrCode) async {
    final query = await _db
        .collection('bikes')
        .where('qrCode', isEqualTo: qrCode.trim())
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return BikeModel.fromFirestore(query.docs.first);
    }
    return null;
  }

  // 5 Durak ve 20 Bisiklet Tohumlama (Seed Data)
  Future<void> seedInitialCampusData() async {
    final stationSnap = await _db.collection('stations').get();
    if (stationSnap.docs.isNotEmpty) return;

    final stations = [
      {'id': 'eng', 'name': 'Mühendislik Fakültesi', 'code': 'MÜH', 'qrCode': 'HKU_STATION_ENG', 'capacity': 8, 'mapX': 70.0, 'mapY': 80.0},
      {'id': 'health', 'name': 'Sağlık Bilimleri Fakültesi', 'code': 'SĞL', 'qrCode': 'HKU_STATION_HEALTH', 'capacity': 6, 'mapX': 270.0, 'mapY': 60.0},
      {'id': 'edu', 'name': 'Eğitim Fakültesi', 'code': 'EĞT', 'qrCode': 'HKU_STATION_EDU', 'capacity': 6, 'mapX': 120.0, 'mapY': 240.0},
      {'id': 'law', 'name': 'Hukuk Fakültesi', 'code': 'HUK', 'qrCode': 'HKU_STATION_LAW', 'capacity': 6, 'mapX': 360.0, 'mapY': 200.0},
      {'id': 'sports_dorms', 'name': 'Golf Sahası & Spor / Yurtlar', 'code': 'SPOR', 'qrCode': 'HKU_STATION_SPORTS', 'capacity': 10, 'mapX': 250.0, 'mapY': 170.0},
    ];

    for (var st in stations) {
      await _db.collection('stations').doc(st['id'] as String).set({
        'name': st['name'],
        'code': st['code'],
        'qrCode': st['qrCode'],
        'capacity': st['capacity'],
        'mapX': st['mapX'],
        'mapY': st['mapY'],
      });
    }

    final List<Map<String, dynamic>> initialBikes = [];

    for (int i = 1; i <= 4; i++) {
      initialBikes.add({'id': 'bike_$i', 'qrCode': 'HKU_BIKE_00$i', 'stationId': 'eng', 'status': 'available', 'batteryLevel': 90 + i});
    }
    for (int i = 5; i <= 8; i++) {
      initialBikes.add({'id': 'bike_$i', 'qrCode': 'HKU_BIKE_00$i', 'stationId': 'health', 'status': 'available', 'batteryLevel': 80 + i});
    }
    for (int i = 9; i <= 12; i++) {
      final codeStr = i < 10 ? '00$i' : '0$i';
      initialBikes.add({'id': 'bike_$i', 'qrCode': 'HKU_BIKE_$codeStr', 'stationId': 'edu', 'status': 'available', 'batteryLevel': 85});
    }
    for (int i = 13; i <= 16; i++) {
      initialBikes.add({'id': 'bike_$i', 'qrCode': 'HKU_BIKE_0$i', 'stationId': 'law', 'status': 'available', 'batteryLevel': 95});
    }
    for (int i = 17; i <= 20; i++) {
      initialBikes.add({'id': 'bike_$i', 'qrCode': 'HKU_BIKE_0$i', 'stationId': 'sports_dorms', 'status': 'available', 'batteryLevel': 100});
    }

    for (var bike in initialBikes) {
      await _db.collection('bikes').doc(bike['id'] as String).set(bike);
    }
  }
}