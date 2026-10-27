import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.userChanges();

  bool _isValidCampusEmail(String email) {
    return email.endsWith('@std.hku.edu.tr') || email.endsWith('@hku.edu.tr');
  }

  // Kayıt Ol
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String schoolNo,
    required String phoneNumber,
    required String department,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    if (!_isValidCampusEmail(cleanEmail)) {
      throw const FormatException(
        'Sadece @std.hku.edu.tr veya @hku.edu.tr uzantılı e-posta adresleri kabul edilmektedir.',
      );
    }

    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: cleanEmail,
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      await user.sendEmailVerification();

      final newUser = UserModel(
        uid: user.uid,
        email: cleanEmail,
        fullName: fullName.trim(),
        schoolNo: schoolNo.trim(),
        phoneNumber: phoneNumber.trim(),
        department: department.trim(),
        role: 'student',
        createdAt: DateTime.now(),
      );

      await _db.collection('users').doc(user.uid).set(newUser.toMap());
    }

    return userCredential;
  }

  // Giriş Yap
  Future<UserCredential> signInWithEmail(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await userCredential.user?.reload();
    final updatedUser = _auth.currentUser;

    if (updatedUser != null && !updatedUser.emailVerified) {
      await _auth.signOut();
      throw const FormatException('UNVERIFIED_EMAIL');
    }

    return userCredential;
  }

  // Doğrulama E-postasını Yeniden Gönder
  Future<void> resendVerificationEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.sendEmailVerification();
    await _auth.signOut();
  }

  // Şifre Sıfırlama
  Future<void> sendPasswordResetEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (!_isValidCampusEmail(cleanEmail)) {
      throw const FormatException('Sadece @std.hku.edu.tr veya @hku.edu.tr uzantılı adresler kabul edilir.');
    }
    await _auth.sendPasswordResetEmail(email: cleanEmail);
  }

  // Profil Çekme
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Çıkış Yap
  Future<void> signOut() async {
    await _auth.signOut();
  }
}