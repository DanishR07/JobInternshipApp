import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  Stream<User?> get authStateChanges => FirebaseAuth.instance.authStateChanges();

  Future<UserCredential> login(String email, String password) {
    return FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signup(String email, String password) {
    return FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
  }

  User? getLoggedInUser() {
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> resetPassword(String email) {
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<void> sendVerificationEmail() {
    User? user = getLoggedInUser();
    if (user == null) return Future.value();
    return user.sendEmailVerification();
  }

  Future<void> changePassword(String newPassword) {
    User? user = getLoggedInUser();
    if (user == null) return Future.value();
    return user.updatePassword(newPassword);
  }

  Future<void> changeName(String name) {
    User? user = getLoggedInUser();
    if (user == null) return Future.value();
    return user.updateDisplayName(name);
  }

  /// ✅ UPDATED: Remove FCM token before logout
  Future<void> logout() async {
    try {
      await _removeFcmToken(); // Remove FCM token first
    } catch (e) {
      print("⚠️ Error removing FCM token: $e");
    }

    await FirebaseAuth.instance.signOut();
  }

  /// 🧹 Remove FCM token from Firestore
  Future<void> _removeFcmToken() async {
    final user = getLoggedInUser();
    if (user == null) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    await userRef.update({
      'fcmTokens': FieldValue.arrayRemove([token]),
    });

    print('✅ FCM token removed from Firestore on logout.');
  }
}
