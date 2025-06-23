import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/Notification.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get stream of user notifications
  Stream<List<UserNotification>> getUserNotificationsStream(String userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserNotification.fromFirestore(doc))
          .toList();
    });
  }

  // Get stream of unread notification count
  Stream<int> getUnreadNotificationCountStream(String userId) {
    if (userId.isEmpty) {
      return Stream.value(0);
    }

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead(String userId) async {
    final batch = _firestore.batch();

    final notifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  // Clear all notifications for a user
  Future<void> clearAllNotifications(String userId) async {
    final batch = _firestore.batch();

    final notifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .get();

    for (var doc in notifications.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Create a notification
  Future<void> createNotification(UserNotification notification) async {
    try {
      // Only check for very recent duplicates (within 5 minutes)
      final exists = await _checkForDuplicateNotification(
          notification.userId,
          notification.applicationId ?? '',
          notification.message
      );

      if (exists) {
        print('⚠️ Recent similar notification already exists, skipping creation');
        return;
      }

      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toMap());

      print('✅ Notification created successfully');
      print('📄 Notification ID: ${notification.id}');
      print('👤 User ID: ${notification.userId}');
      print('📝 Message: ${notification.message}');
      print('⏰ Timestamp: ${notification.timestamp}');
    } catch (e) {
      print('❌ Error creating notification: $e');
      // Still create the notification even if checking for duplicates fails
      // This ensures users don't miss important updates
      try {
        await _firestore
            .collection('notifications')
            .doc(notification.id)
            .set(notification.toMap());
        print('✅ Notification created after error recovery');
      } catch (e2) {
        print('❌ Failed to create notification after error recovery: $e2');
        throw e2;
      }
    }
  }

  // Create a notification for application status update
  Future<void> createStatusUpdateNotification({
    required String userId,
    required String applicationId,
    required String positionType,
    required String positionId,
    required String positionTitle,
    required String companyName,
    required String newStatus,
  }) async {
    try {
      final message = 'Your application for $positionTitle at $companyName has been updated to: $newStatus';

      // Create notification object
      final notification = UserNotification(
        id: _firestore.collection('notifications').doc().id,
        userId: userId,
        title: 'Application Status Updated',
        message: message,
        timestamp: DateTime.now(),
        isRead: false,
        applicationId: applicationId,
        positionType: positionType,
        positionId: positionId,
      );

      await createNotification(notification);
    } catch (e) {
      print('❌ Error creating status update notification: $e');
      throw e;
    }
  }

  // Debug method to check user's FCM token and recent notifications
  Future<void> debugUserNotifications(String userId) async {
    try {
      print('🔍 DEBUG: Checking notifications for user: $userId');

      // Check recent notifications
      final notificationsSnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();

      print('📊 Found ${notificationsSnapshot.docs.length} recent notifications:');
      for (var doc in notificationsSnapshot.docs) {
        final notification = UserNotification.fromFirestore(doc);
        print('  - ${notification.title}: ${notification.message}');
        print('    Created: ${notification.timestamp}');
        print('    Read: ${notification.isRead}');
        print('    ID: ${notification.id}');
      }

      // Check user's FCM token
      final userSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>;
        final fcmToken = userData['fcmToken'] as String?;
        final lastTokenUpdate = userData['lastTokenUpdate'] as Timestamp?;

        print('📱 User FCM Token: ${fcmToken?.substring(0, 20)}...');
        print('⏰ Token last updated: ${lastTokenUpdate?.toDate()}');
        print('📧 User email: ${userData['email']}');
        print('🔄 User active: ${userData['isActive']}');
      } else {
        print('❌ User document not found');
      }

    } catch (e) {
      print('❌ Error debugging user notifications: $e');
    }
  }

  // Check for duplicate notifications using a simple approach that doesn't require composite indexes
  Future<bool> _checkForDuplicateNotification(String userId, String applicationId, String message) async {
    try {
      print('🔍 Checking for duplicate notifications...');

      // Only check for duplicates within the last 5 minutes to avoid blocking legitimate updates
      final fiveMinutesAgo = DateTime.now().subtract(Duration(minutes: 5));

      // First, try to find by userId and applicationId (if available)
      if (applicationId.isNotEmpty) {
        final snapshot = await _firestore
            .collection('notifications')
            .where('userId', isEqualTo: userId)
            .where('applicationId', isEqualTo: applicationId)
            .orderBy('timestamp', descending: true)
            .limit(3)
            .get();

        // Check the messages in code
        for (var doc in snapshot.docs) {
          final notification = UserNotification.fromFirestore(doc);

          // Only consider it a duplicate if it's very recent (within 5 minutes)
          if (notification.timestamp.isAfter(fiveMinutesAgo)) {
            final currentStatus = _extractStatusFromMessage(notification.message);
            final newStatus = _extractStatusFromMessage(message);

            if (currentStatus == newStatus) {
              print('✅ Found recent duplicate notification with same status: $currentStatus');
              return true;
            }
          }
        }
      }

      print('✅ No recent duplicate notification found');
      return false;
    } catch (e) {
      print('❌ Error checking for duplicate notifications: $e');
      // If there's an error, assume no duplicate to ensure notification delivery
      return false;
    }
  }

  // Extract status from message (e.g., "updated to: Accepted" -> "Accepted")
  String _extractStatusFromMessage(String message) {
    final regex = RegExp(r'updated to: (.+)$');
    final match = regex.firstMatch(message);
    return match?.group(1) ?? '';
  }

  // Check if two messages are similar enough to be considered duplicates
  bool _messagesAreSimilar(String message1, String message2) {
    // If messages are identical, they're definitely similar
    if (message1 == message2) return true;

    // If both contain the same status, they're similar
    final status1 = _extractStatusFromMessage(message1);
    final status2 = _extractStatusFromMessage(message2);

    if (status1.isNotEmpty && status2.isNotEmpty && status1 == status2) {
      return true;
    }

    // Otherwise, not similar enough
    return false;
  }
}
