import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip_model.dart';
import '../../../home/data/models/bike_model.dart';
import '../../../home/data/models/station_model.dart';

class TripService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Kullanıcının Aktif Sürüşünü Canlı Takip Et
  Stream<TripModel?> getActiveTripStream(String userId) {
    return _db
        .collection('trips')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snap) => snap.docs.isNotEmpty ? TripModel.fromFirestore(snap.docs.first) : null);
  }

  // 2. Bisiklet QR Okutulunca Sürüş Başlat
  Future<TripModel> startTrip({
    required String userId,
    required String bikeQrCode,
  }) async {
    final bikeQuery = await _db
        .collection('bikes')
        .where('qrCode', isEqualTo: bikeQrCode.trim())
        .limit(1)
        .get();

    if (bikeQuery.docs.isEmpty) {
      throw Exception('Geçersiz Bisiklet QR Kodu!');
    }

    final bikeDoc = bikeQuery.docs.first;
    final bike = BikeModel.fromFirestore(bikeDoc);

    if (bike.status != 'available') {
      throw Exception('Bu bisiklet şu an kullanımda veya bakımda.');
    }

    String startStationName = 'Kampüs İçi';
    if (bike.stationId != null) {
      final stationDoc = await _db.collection('stations').doc(bike.stationId).get();
      if (stationDoc.exists) {
        startStationName = stationDoc.data()?['name'] ?? 'Kampüs İçi';
      }
    }

    final tripRef = _db.collection('trips').doc();
    final newTrip = TripModel(
      id: tripRef.id,
      userId: userId,
      bikeId: bike.id,
      bikeQrCode: bike.qrCode,
      startStationId: bike.stationId ?? 'unknown',
      startStationName: startStationName,
      startTime: DateTime.now(),
      status: 'active',
    );

    final batch = _db.batch();
    batch.set(tripRef, newTrip.toMap());

    batch.update(_db.collection('bikes').doc(bike.id), {
      'status': 'in_use',
      'stationId': null,
      'currentUserId': userId,
    });

    await batch.commit();
    return newTrip;
  }

  // 3. Durak QR Kodunu Doğrula
  Future<StationModel> validateEndStation(String stationQrCode) async {
    final stationQuery = await _db
        .collection('stations')
        .where('qrCode', isEqualTo: stationQrCode.trim())
        .limit(1)
        .get();

    if (stationQuery.docs.isEmpty) {
      throw Exception('Geçersiz Durak QR Kodu!');
    }

    return StationModel.fromFirestore(stationQuery.docs.first);
  }

  // 4. Fotoğrafı Base64'e Çevir ve Firestore'a Kaydet (Storage Gerekmez)
  Future<void> completeTrip({
    required TripModel activeTrip,
    required StationModel endStation,
    required File photoFile,
  }) async {
    final now = DateTime.now();
    final durationMinutes = now.difference(activeTrip.startTime).inMinutes;

    // Fotoğrafı byte dizisine dönüştürüp Base64 metni yapıyoruz (~50 KB)
    final bytes = await photoFile.readAsBytes();
    final String base64Photo = base64Encode(bytes);

    final batch = _db.batch();

    batch.update(_db.collection('trips').doc(activeTrip.id), {
      'endStationId': endStation.id,
      'endStationName': endStation.name,
      'endTime': Timestamp.fromDate(now),
      'durationMinutes': durationMinutes < 1 ? 1 : durationMinutes,
      'status': 'completed',
      'photoUrl': base64Photo, // Base64 verisi doğrudan Firestore'a yazılıyor
    });

    batch.update(_db.collection('bikes').doc(activeTrip.bikeId), {
      'status': 'available',
      'stationId': endStation.id,
      'currentUserId': null,
    });

    await batch.commit();
  }

  // 5. Kullanıcının Geçmiş Sürüşleri
  Stream<List<TripModel>> getTripHistoryStream(String userId) {
    return _db
        .collection('trips')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .map((snap) => snap.docs.map((d) => TripModel.fromFirestore(d)).toList());
  }
}