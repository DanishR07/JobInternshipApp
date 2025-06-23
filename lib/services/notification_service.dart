import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../data/notification_repository.dart';

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  print('Message data: ${message.data}');
  print('Message notification: ${message.notification?.title}');
}

class NotificationService extends GetxController {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  final NotificationRepository _notificationRepository = Get.find();

  // Observable for FCM token
  final RxString fcmToken = ''.obs;
  final RxBool isInitialized = false.obs;
  final RxBool isWebPlatform = false.obs;

  @override
  void onInit() {
    super.onInit();
    isWebPlatform.value = kIsWeb;
    _initializeNotifications().then((_) {
      // Ensure current user is registered after initialization
      ensureUserRegistered();
    });
  }

  Future<void> _initializeNotifications() async {
    try {
      // Skip FCM initialization on web for now
      if (kIsWeb) {
        print('🌐 Running on web - FCM features limited');
        isInitialized.value = true;
        return;
      }

      // Request permission for iOS and Android 13+
      await _requestPermission();

      // Initialize local notifications (mobile only)
      await _initializeLocalNotifications();

      // Create notification channel for Android
      await _createNotificationChannel();

      // Get and save FCM token
      await _getFCMToken();

      // Set up token refresh listener
      _setupTokenRefreshListener();

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle app launch from notification
      await _handleAppLaunchFromNotification();

      isInitialized.value = true;
      print('✅ Notification service initialized successfully');
    } catch (e) {
      print('❌ Error initializing notifications: $e');
      // Still mark as initialized to prevent blocking the app
      isInitialized.value = true;
    }
  }

  Future<void> _requestPermission() async {
    if (kIsWeb) return;

    try {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('Permission granted: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('⚠️ User granted provisional permission');
      } else {
        print('❌ User declined or has not accepted permission');
      }
    } catch (e) {
      print('Error requesting permission: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    if (kIsWeb) return;

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      const InitializationSettings initializationSettings =
      InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      print('✅ Local notifications initialized');
    } catch (e) {
      print('Error initializing local notifications: $e');
    }
  }

  Future<void> _createNotificationChannel() async {
    if (kIsWeb) return;

    try {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'career_compass_channel',
        'CareerCompass Notifications',
        description: 'Notifications for job application updates and career opportunities',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
        enableLights: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      print('✅ Android notification channel created');
    } catch (e) {
      print('Error creating notification channel: $e');
    }
  }

  Future<String?> _getFCMToken() async {
    if (kIsWeb) {
      print('🌐 FCM tokens not supported on web');
      return null;
    }

    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        fcmToken.value = token;
        print('📱 FCM Token: $token');

        // Save token to user's profile in Firestore
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await _saveTokenToUserProfile(user.uid, token);
        }
      }
      return token;
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }

  void _setupTokenRefreshListener() {
    if (kIsWeb) return;

    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      fcmToken.value = newToken;
      print('🔄 FCM Token refreshed: $newToken');

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _saveTokenToUserProfile(user.uid, newToken);
      }
    });
  }

  // 🔧 ENHANCED: Save FCM token and ensure user document exists
  Future<void> _saveTokenToUserProfile(String userId, String token) async {
    try {
      print('💾 Saving FCM token and ensuring user document exists...');
      print('👤 User ID: $userId');
      print('📱 Token: ${token.substring(0, 20)}...');

      // Get current user info
      final currentUser = FirebaseAuth.instance.currentUser;
      final userEmail = currentUser?.email ?? 'unknown@email.com';
      final userName = currentUser?.displayName ?? 'Unknown User';

      // Prepare user data with FCM token
      final userData = {
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
        'platform': kIsWeb ? 'web' : 'mobile',
        'email': userEmail,
        'displayName': userName,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      // Always ensure user document exists in users collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({
        ...userData,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('✅ User document created/updated in users collection');

      // Also check if userProfiles exists and update it
      final userProfileDoc = await FirebaseFirestore.instance
          .collection('userProfiles')
          .doc(userId)
          .get();

      if (userProfileDoc.exists) {
        await FirebaseFirestore.instance
            .collection('userProfiles')
            .doc(userId)
            .update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
          'platform': kIsWeb ? 'web' : 'mobile',
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
        print('✅ FCM token also updated in userProfiles collection');
      }

      print('✅ FCM token saved successfully for user: $userId');
    } catch (e) {
      print('❌ Error saving FCM token to user profile: $e');
      print('🔍 Stack trace: ${StackTrace.current}');
    }
  }

// 🔧 NEW: Ensure user is registered for notifications
  Future<void> ensureUserRegistered() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('⚠️ No current user - cannot register for notifications');
        return;
      }

      print('🔄 Ensuring user is registered for notifications...');
      print('👤 User ID: ${currentUser.uid}');
      print('📧 Email: ${currentUser.email}');

      // Get fresh FCM token
      final token = await _getFCMToken();
      if (token != null) {
        print('✅ User registration for notifications completed');
      } else {
        print('⚠️ Could not get FCM token during registration');
      }
    } catch (e) {
      print('❌ Error ensuring user registration: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kIsWeb) return;

    print('📨 Handling foreground message: ${message.messageId}');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');

    _showLocalNotification(message);
  }

  void _handleNotificationTap(RemoteMessage message) {
    print('👆 Message clicked: ${message.data}');
    _navigateToNotificationPage(message.data);
  }

  Future<void> _handleAppLaunchFromNotification() async {
    if (kIsWeb) return;

    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('🚀 App launched from notification: ${initialMessage.data}');
      _navigateToNotificationPage(initialMessage.data);
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    print('👆 Local notification tapped: ${response.payload}');

    if (response.payload != null) {
      try {
        // Parse payload if it contains navigation data
        final data = response.payload!.split('|');
        if (data.length >= 2) {
          final route = data[0];
          final id = data[1];
          Get.toNamed(route, arguments: {'id': id});
        } else {
          Get.toNamed('/notifications');
        }
      } catch (e) {
        Get.toNamed('/notifications');
      }
    } else {
      Get.toNamed('/notifications');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    if (kIsWeb) return;

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'career_compass_channel',
        'CareerCompass Notifications',
        channelDescription: 'Notifications for job application updates',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        enableLights: true,
        color: Color(0xFF2196F3),
        ledColor: Color(0xFF2196F3),
        ledOnMs: 1000,
        ledOffMs: 500,
        ticker: 'CareerCompass Notification',
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      // Create payload for navigation
      String payload = '/notifications';
      if (message.data.containsKey('type') && message.data.containsKey('id')) {
        payload = '${_getRouteFromType(message.data['type'])}|${message.data['id']}';
      }

      await _localNotifications.show(
        message.hashCode,
        message.notification?.title ?? 'CareerCompass',
        message.notification?.body ?? 'You have a new notification',
        platformChannelSpecifics,
        payload: payload,
      );

      print('✅ Local notification displayed');
    } catch (e) {
      print('Error showing local notification: $e');
    }
  }

  // Test method to show a local notification directly
  Future<void> showTestNotification({
    required String title,
    required String body,
  }) async {
    if (kIsWeb) return;

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'career_compass_channel',
        'CareerCompass Notifications',
        channelDescription: 'Notifications for job application updates',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        playSound: true,
        enableVibration: true,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _localNotifications.show(
        DateTime.now().millisecond,
        title,
        body,
        platformChannelSpecifics,
        payload: '/notifications',
      );

      print('✅ Test notification displayed');
    } catch (e) {
      print('Error showing test notification: $e');
    }
  }

  String _getRouteFromType(String type) {
    switch (type) {
      case 'application_status':
        return '/applied_positions';
      case 'new_job':
        return '/user_jobs';
      case 'new_internship':
        return '/user_internships';
      default:
        return '/notifications';
    }
  }

  void _navigateToNotificationPage(Map<String, dynamic> data) {
    // Navigate based on notification type
    if (data['type'] == 'application_status') {
      Get.toNamed('/applied_positions');
    } else if (data['type'] == 'new_job') {
      Get.toNamed('/user_jobs');
    } else if (data['type'] == 'new_internship') {
      Get.toNamed('/user_internships');
    } else {
      Get.toNamed('/notifications');
    }
  }

  // Method to send notification when admin updates status
  Future<void> sendStatusUpdateNotification({
    required String userId,
    required String applicationId,
    required String positionTitle,
    required String companyName,
    required String newStatus,
  }) async {
    try {
      // Create notification in Firestore (works on all platforms)
      await _notificationRepository.createStatusUpdateNotification(
        userId: userId,
        applicationId: applicationId,
        positionType: 'job', // or 'internship'
        positionId: applicationId,
        positionTitle: positionTitle,
        companyName: companyName,
        newStatus: newStatus,
      );

      print('✅ Notification sent for status update: $newStatus');
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }

  // Method to get current FCM token
  Future<String?> getCurrentToken() async {
    if (kIsWeb) return null;

    if (fcmToken.value.isNotEmpty) {
      return fcmToken.value;
    }
    return await _getFCMToken();
  }

  // Method to refresh FCM token
  Future<void> refreshToken() async {
    if (kIsWeb) return;

    try {
      await _firebaseMessaging.deleteToken();
      await _getFCMToken();
    } catch (e) {
      print('❌ Error refreshing token: $e');
    }
  }

  // Method to subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    if (kIsWeb) return;

    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ Subscribed to topic: $topic');
    } catch (e) {
      print('❌ Error subscribing to topic: $e');
    }
  }

  // Method to unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (kIsWeb) return;

    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ Error unsubscribing to topic: $e');
    }
  }
}
