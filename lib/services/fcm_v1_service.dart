// services/fcm_v1_service.dart

import 'dart:convert';
import 'package:final_lab/services/user_registaration_service.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FCMV1Service {
  static const String _serviceAccountJson = '''
  
  {
  "type": "service_account",
  "project_id": "final-lab-project-219",
  "private_key_id": "6dc3fc105e33fec778b494c3368e8b17b997c816",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCp/XVN8MeKQwKv\niD1FtrLQ6z2Bwq/KYT+NlgXFhsOdbQeC0WQzOojkqCIEfTnJtWls0TmCoORDEoOF\nZySvikjBlE1nUWRuXsW2f2jOTbNCW+5Q1WMpFukJg63J8LubDb3RRymWa8tnKZ2I\nI3gYC9pMHy7BsQNuOvRckdJa/n1U7XYzCyZJop3fQJRa2O+l7MtbuDthfwrJZXT4\nb8SK2CRY50TCWqKvdOmwg4UGKGFLhswy8UYPqwqf1/VF02FCUDr/MBGQz0Q+Vhyl\n3hOlw2jg0Dc+Itc0Au0+6PDa9CuotMr+igkc0f5Ckzr9nRFRPCsH3rwmhKBqVLq0\n7jSr2HndAgMBAAECggEASrqQN3/KkKcNxrHLUdrTuFE53FIEaqEeybTye5fXZdz4\n6NL5TCYG6RJaxgNxBJH6Myq1MA5f2naIl/w0XfEaM/NopatbzcNfAm/3WH5C+ECm\nvyVXrsgSESswmq54It1DHX29tBFWPVdHmAITuOp5AG7S5LZXDj3fj9RRF8x5t3vm\nayVDZEcIpBkBb/2M3iWXey8NQuJgX23ZO3dsO9CJ3O2+3P/wCM2iWiNw3GLBZtIr\nrfblnzODVHzBA5x1Q/qHHtlQrsySmXvFKqo1c0TOfRdUrhc7EF4+ucreK2VRw0F9\nl1OJEg5XlmkOqJAf6B53IcVhmMpRxbYXr6beJ9UahwKBgQDl5A+r1OIki/l1hq+B\nOMTAexa7ErmIlM4JZZ78eg85y25ST6+qNChGZrhd49pYlzkbdrZIN3eYWv1dN9wv\nHFv9FWX0FPpfeVEQzWhapLS0JuBMtK21CkV0t7+maVmqmZy0hDb4lckOqAUNrgi9\nH7PtLcryuQ+iRuMpIugKkG/P+wKBgQC9S9FDJaA016nu14MH822Fztdsm9lO2R2/\nYVEQ+F+fx7nOJdpqTf6QDYdLDSSCQT87wScEEEk2I8ffNAFctyyQCjomTBme3sIW\nTfXZKDSQv82lcDpAVnxKD2UuL1/bgVx9qyL8N/CouaCQs0GQUzAO5eLeORBCj+cv\nN6k2olE+BwKBgQC2EMN0g7nB1fVv5YYTYiE4i4M6Dx9PEwKGIKwkKorqa7loiOGH\ne501/F4hRbYEGWfJ31+HnB4kVFN6QyYnTV9w9UR0ZTTQ7iSMmRD/UJgoYO2c8i7s\nRUEyqd+nbKHt4ZBgyqE6iG3eJKUz61PSbEw0F+M2DehazadUSefZjgBvhwKBgQC3\nBQr6pPJUpP+EEZJ6qX2HFglq1PQyK/F7DBhZFAtAbNbU3fxjM62gkbPxeG+IEJWW\nrJWQdD6UvduNjraScff//CNky8cpt65n6lB8+UZ5fTjTb8KiWfwpjuEA2oUPse8/\nAav9uAhS2cbIoMgPRp78iH/k47842/Fl0aclT6LFGQKBgHXCOjDB2vrrYdeRYwOa\nxMq/CdYWxbynzkCXQK5ysfrqNzQzYxpUQ1Q7cM+zj++iXD5ppD97qKrWKuNepkJS\nfSYm5D8bCettSVrU/PVuVhMDX7k88Hd47Pc7qd5MvBjgoAdMjuqGroTbAu+Inn0Y\nvejqY7vRIfg8VjuGfNwzojUa\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-fbsvc@final-lab-project-219.iam.gserviceaccount.com",
  "client_id": "112628589699453789439",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40final-lab-project-219.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}

  
''';

  static const String _projectId = 'final-lab-project-219';
  static const String _fcmScope =
      'https://www.googleapis.com/auth/firebase.messaging';

  static Future<String?> _getAccessToken() async {
    try {
      print('🔑 Getting OAuth2 access token...');

      final jsonString = await rootBundle.loadString('assets/service_account.json');
      final serviceAccountMap = json.decode(jsonString);

      print('✅ Service account JSON parsed successfully');

      final serviceAccount = ServiceAccountCredentials.fromJson(
        serviceAccountMap,
      );
      final client = http.Client();

      final accessCredentials = await obtainAccessCredentialsViaServiceAccount(
        serviceAccount,
        [_fcmScope],
        client,
      );

      client.close();

      final token = accessCredentials.accessToken.data;
      print('✅ Access token obtained: ${token.substring(0, 20)}...');

      return token;
    } catch (e) {
      print('❌ Error getting access token: $e');
      print('🔍 Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  static Future<bool> sendNotificationWithToken({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      print('📤 Sending FCM V1 notification directly...');
      print('📱 To Token: ${token.substring(0, 30)}...');
      print('📝 Title: $title');
      print('📝 Body: $body');

      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        print('❌ Failed to get access token');
        return false;
      }

      final url =
          'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final message = {
        'message': {
          'token': token,
          'notification': {'title': title, 'body': body},
          'data': {
            'title': title,
            'body': body,
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            ...?data?.map((key, value) => MapEntry(key, value.toString())),
          },
          'android': {
            'priority': 'HIGH', // Delivery priority for the message itself
            'notification': {
              'channel_id': 'career_compass_channel',
              'sound': 'default',
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'tag': 'career_compass',
              // 'importance': 'HIGH', // Removed as it's not a valid field here for FCM V1
            },
          },
          'apns': {
            'headers': {'apns-priority': '10'},
            'payload': {
              'aps': {
                'alert': {'title': title, 'body': body},
                'sound': 'default',
                'badge': 1,
                'content-available': 1,
              },
            },
          },
        },
      };

      print('📦 Message payload: ${json.encode(message)}');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(message),
      );

      print('📥 FCM V1 Response Status: ${response.statusCode}');
      print('📥 FCM V1 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ FCM V1 notification sent successfully');
        final responseData = json.decode(response.body);
        print('📨 Message ID: ${responseData['name']}');
        return true;
      } else {
        print('❌ Failed to send FCM V1 notification');
        print('❌ Status: ${response.statusCode}');
        print('❌ Body: ${response.body}');

        // Handle UNREGISTERED token error
        if (response.statusCode == 404 &&
            response.body.contains('UNREGISTERED')) {
          print('🔄 Token is UNREGISTERED - attempting to refresh...');
          // You would typically need to remove this token from the user's stored tokens in Firestore
          // and then trigger a token refresh on the affected device if the user is still active.
          // Example:
          // await _removeInvalidToken(token, userId);
          // await _refreshUserToken(); // This might trigger a new token to be saved
        }

        return false;
      }
    } catch (e) {
      print('❌ Error sending FCM V1 notification: $e');
      print('🔍 Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  // Placeholder for a function to remove an invalid token from Firestore
  // static Future<void> _removeInvalidToken(String token, String userId) async {
  //   try {
  //     final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
  //     await userRef.update({
  //       'fcmTokens': FieldValue.arrayRemove([token]),
  //     });
  //     print('🗑️ Removed invalid token $token for user $userId from Firestore.');
  //   } catch (e) {
  //     print('❌ Error removing invalid token from Firestore: $e');
  //   }
  // }

  static Future<void> _refreshUserToken() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        print('🔄 Refreshing FCM token for current user...');
        // This will trigger the notification service to get a new token
        // You might want to call your notification service refresh method here
        // Get.find<NotificationService>().getAndSaveToken(); // Example if you have this in NotificationService
      }
    } catch (e) {
      print('❌ Error refreshing user token: $e');
    }
  }

  static Future<bool> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      print('🔍 Looking for FCM tokens for user: $userId');

      await UserRegistrationService.ensureUserDocumentExists(userId);

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.uid == userId) {
        print('🎯 Target user is current user - checking for fresh token...');
        try {
          // This part still needs proper implementation if you want to get a fresh token from NotificationService.
          // For now, it will proceed to fetch from Firestore.
          print(
            '💡 Consider using current session token for better reliability',
          );
        } catch (e) {
          print('⚠️ Could not get fresh token from notification service: $e');
        }
      }

      DocumentSnapshot? userDoc;
      Map<String, dynamic>? userData;

      try {
        userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();

        if (userDoc.exists) {
          userData = userDoc.data() as Map<String, dynamic>?;
          print('📄 Found user in users collection');
        }
      } catch (e) {
        print('⚠️ Error checking users collection: $e');
      }

      if (userData == null) {
        print('❌ User document not found: $userId');
        print('💡 User may need to log in to register FCM tokens');
        return false;
      }

      print('📄 User document data: $userData');

      List<String> fcmTokens = [];

      // Prefer 'fcmTokens' list, fallback to single 'fcmToken' string
      if (userData.containsKey('fcmTokens') && userData['fcmTokens'] is List) {
        fcmTokens = List<String>.from(userData['fcmTokens']);
        print('📱 Found FCM tokens list: ${fcmTokens.length} tokens');
      } else if (userData.containsKey('fcmToken') &&
          userData['fcmToken'] is String) {
        fcmTokens = [userData['fcmToken'] as String];
        print('📱 Found single FCM token (legacy field)');
      }

      if (fcmTokens.isEmpty) {
        print('❌ No FCM tokens found for user: $userId');
        print('📄 Available fields: ${userData.keys.toList()}');
        print(
          '💡 User needs to open the app on a device to register FCM token(s)',
        );
        return false;
      }

      bool overallSuccess = true;
      for (final token in fcmTokens) {
        print(
          'Attempting to send notification to token: ${token.substring(0, 20)}...',
        );
        final success = await sendNotificationWithToken(
          token: token,
          title: title,
          body: body,
          data: data,
        );
        if (!success) {
          overallSuccess = false;
          print(
            '❌ Notification failed for token: ${token.substring(0, 20)}...',
          );
          // Here, you would typically remove the invalid token from Firestore.
          // await _removeInvalidToken(token, userId);
        } else {
          print(
            '✅ Notification sent successfully to token: ${token.substring(0, 20)}...',
          );
        }
      }

      return overallSuccess;
    } catch (e) {
      print('❌ Error sending notification to user: $e');
      print('🔍 Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  static Future<bool> sendApplicationStatusNotification({
    required String userId,
    required String applicationId,
    required String positionType,
    required String positionId,
    required String positionTitle,
    required String companyName,
    required String newStatus,
  }) async {
    print('📢 Sending application status notification (V1)...');
    print('👤 User ID: $userId');
    print('📋 Application ID: $applicationId');
    print('💼 Position: $positionTitle at $companyName');
    print('📊 New Status: $newStatus');

    final title = 'Application Update';
    final body =
        'Your application for $positionTitle at $companyName is now $newStatus';

    final data = {
      'type': 'application_status',
      'applicationId': applicationId,
      'positionTitle': positionTitle,
      'companyName': companyName,
      'status': newStatus,
      'route': '/notifications',
    };

    return await sendNotificationToUser(
      userId: userId,
      title: title,
      body: body,
      data: data,
    );
  }

  static Future<bool> sendTestNotification({required String userId}) async {
    final title = 'CareerCompass Test (V1)';
    final body = 'Test notification from V1 API! 🚀';

    final data = {
      'type': 'test',
      'route': '/notifications',
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    return await sendNotificationToUser(
      userId: userId,
      title: title,
      body: body,
      data: data,
    );
  }

  static Future<bool> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        print('❌ Failed to get access token for topic notification');
        return false;
      }

      final url =
          'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final message = {
        'message': {
          'topic': topic,
          'notification': {'title': title, 'body': body},
          'data': {
            'title': title,
            'body': body,
            ...?data?.map((key, value) => MapEntry(key, value.toString())),
          },
          'android': {
            'priority': 'HIGH',
            'notification': {
              'channel_id': 'career_compass_channel',
              'sound': 'default',
              // 'importance': 'HIGH', // Removed as it's not a valid field here for FCM V1
            },
          },
        },
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(message),
      );

      if (response.statusCode == 200) {
        print('✅ Topic notification sent successfully (V1)');
        return true;
      } else {
        print('❌ Failed to send topic notification (V1): ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error sending topic notification (V1): $e');
      return false;
    }
  }

  static Future<bool> sendNewJobNotification({
    required String jobId,
    required String jobTitle,
    required String companyName,
  }) async {
    final title = 'New Job Opportunity';
    final body = 'New position: $jobTitle at $companyName';

    final data = {
      'type': 'new_job',
      'jobId': jobId,
      'jobTitle': jobTitle,
      'companyName': companyName,
      'route': '/user_jobs',
    };

    return await sendNotificationToTopic(
      topic: 'new_jobs',
      title: title,
      body: body,
      data: data,
    );
  }

  static Future<bool> sendNewInternshipNotification({
    required String internshipId,
    required String internshipTitle,
    required String companyName,
  }) async {
    final title = 'New Internship Opportunity';
    final body = 'New internship: $internshipTitle at $companyName';

    final data = {
      'type': 'new_internship',
      'internshipId': internshipId,
      'internshipTitle': internshipTitle,
      'companyName': companyName,
      'route': '/user_internships',
    };

    return await sendNotificationToTopic(
      topic: 'new_internships',
      title: title,
      body: body,
      data: data,
    );
  }
}
