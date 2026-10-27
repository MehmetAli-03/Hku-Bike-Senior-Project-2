import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String schoolNo;
  final String phoneNumber;
  final String department; // <-- Bölüm alanı eklendi
  final String role; // Varsayılan: 'student'
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.schoolNo,
    required this.phoneNumber,
    required this.department,
    this.role = 'student',
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      schoolNo: map['schoolNo'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      department: map['department'] ?? '',
      role: map['role'] ?? 'student',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'schoolNo': schoolNo,
      'phoneNumber': phoneNumber,
      'department': department,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}