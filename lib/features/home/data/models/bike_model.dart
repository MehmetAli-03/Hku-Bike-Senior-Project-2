import 'package:cloud_firestore/cloud_firestore.dart';

class BikeModel {
  final String id;
  final String qrCode;
  final String? stationId;
  final String status; // 'available', 'in_use', 'maintenance'
  final String? currentUserId;
  final int batteryLevel;

  BikeModel({
    required this.id,
    required this.qrCode,
    this.stationId,
    required this.status,
    this.currentUserId,
    this.batteryLevel = 100,
  });

  factory BikeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return BikeModel(
      id: doc.id,
      qrCode: data['qrCode'] ?? '',
      stationId: data['stationId'],
      status: data['status'] ?? 'available',
      currentUserId: data['currentUserId'],
      batteryLevel: (data['batteryLevel'] ?? 100) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'qrCode': qrCode,
      'stationId': stationId,
      'status': status,
      'currentUserId': currentUserId,
      'batteryLevel': batteryLevel,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }
}