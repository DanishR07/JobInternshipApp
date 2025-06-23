import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'notification_service.dart';

class UserRegistrationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register user when they first sign up or log in
  static Future<void> registerUser(User user) async {
    try {
      print('📝 Registering user in system...');
      print('👤 User ID: ${user.uid}');
      print('📧 Email: ${user.email}');
      print('👤 Display Name: ${user.displayName}');

      // Prepare user data
      final userData = {
        'email': user.email ?? 'unknown@email.com',
        'displayName': user.displayName ?? user.email?.split('@')[0] ?? 'Unknown User',
        'photoURL': user.photoURL,
        'emailVerified': user.emailVerified,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'platform': 'mobile',
        'registrationComplete': true,
      };

      // Create/update user document in users collection
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));

      print('✅ User registered in users collection');

      // Initialize notification service for this user
      try {
        final notificationService = Get.find<NotificationService>();
        await notificationService.ensureUserRegistered();
        print('✅ Notification service initialized for user');
      } catch (e) {
        print('⚠️ Notification service not available: $e');
      }

    } catch (e) {
      print('❌ Error registering user: $e');
      print('🔍 Stack trace: ${StackTrace.current}');
    }
  }

  // Update user's last login time
  static Future<void> updateLastLogin(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
      print('✅ Updated last login for user: $userId');
    } catch (e) {
      print('❌ Error updating last login: $e');
    }
  }

  // Check if user document exists
  static Future<bool> userExists(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      print('❌ Error checking if user exists: $e');
      return false;
    }
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('❌ Error getting user data: $e');
      return null;
    }
  }

  // Ensure user document exists (for existing users)
  static Future<void> ensureUserDocumentExists(String userId) async {
    try {
      final exists = await userExists(userId);
      if (!exists) {
        print('🔧 Creating missing user document for: $userId');

        final currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.uid == userId) {
          await registerUser(currentUser);
        } else {
          // Create minimal user document
          await _firestore
              .collection('users')
              .doc(userId)
              .set({
            'email': 'unknown@email.com',
            'displayName': 'Unknown User',
            'createdAt': FieldValue.serverTimestamp(),
            'lastLoginAt': FieldValue.serverTimestamp(),
            'isActive': true,
            'platform': 'mobile',
            'registrationComplete': false,
          });
          print('✅ Created minimal user document');
        }
      }
    } catch (e) {
      print('❌ Error ensuring user document exists: $e');
    }
  }

  // Clean up inactive users (optional)
  static Future<void> markUserInactive(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
        'isActive': false,
        'lastSeenAt': FieldValue.serverTimestamp(),
      });
      print('✅ Marked user as inactive: $userId');
    } catch (e) {
      print('❌ Error marking user inactive: $e');
    }
  }
}
