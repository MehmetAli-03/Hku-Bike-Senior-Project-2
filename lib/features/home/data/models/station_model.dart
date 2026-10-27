import 'package:cloud_firestore/cloud_firestore.dart';

class StationModel {
  final String id;
  final String name;
  final String code;
  final String qrCode;
  final int capacity;
  final double mapX;
  final double mapY;

  StationModel({
    required this.id,
    required this.name,
    required this.code,
    required this.qrCode,
    required this.capacity,
    required this.mapX,
    required this.mapY,
  });

  factory StationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return StationModel(
      id: doc.id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      qrCode: data['qrCode'] ?? '',
      capacity: (data['capacity'] ?? 0) as int,
      mapX: (data['mapX'] ?? 0.0).toDouble(),
      mapY: (data['mapY'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'qrCode': qrCode,
      'capacity': capacity,
      'mapX': mapX,
      'mapY': mapY,
    };
  }
}