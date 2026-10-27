import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String id;
  final String userId;
  final String bikeId;
  final String bikeQrCode;
  final String startStationId;
  final String startStationName;
  final String? endStationId;
  final String? endStationName;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationMinutes;
  final String status; // 'active' veya 'completed'
  final String? photoUrl;

  TripModel({
    required this.id,
    required this.userId,
    required this.bikeId,
    required this.bikeQrCode,
    required this.startStationId,
    required this.startStationName,
    this.endStationId,
    this.endStationName,
    required this.startTime,
    this.endTime,
    this.durationMinutes,
    required this.status,
    this.photoUrl,
  });

  factory TripModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TripModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      bikeId: data['bikeId'] ?? '',
      bikeQrCode: data['bikeQrCode'] ?? '',
      startStationId: data['startStationId'] ?? '',
      startStationName: data['startStationName'] ?? 'Bilinmeyen Durak',
      endStationId: data['endStationId'],
      endStationName: data['endStationName'],
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp?)?.toDate(),
      durationMinutes: data['durationMinutes'],
      status: data['status'] ?? 'active',
      photoUrl: data['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'bikeId': bikeId,
      'bikeQrCode': bikeQrCode,
      'startStationId': startStationId,
      'startStationName': startStationName,
      'endStationId': endStationId,
      'endStationName': endStationName,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'durationMinutes': durationMinutes,
      'status': status,
      'photoUrl': photoUrl,
    };
  }
}