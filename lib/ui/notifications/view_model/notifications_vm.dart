import 'package:final_lab/ui/applied_positions/applied_positions_page.dart';
import 'package:final_lab/ui/user_home/home.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../../data/AuthRepository.dart';
import '../../../data/notification_repository.dart';
import '../../../model/Notification.dart';
import '../../user_home/user_home.dart';

class NotificationsViewModel extends GetxController {
  final AuthRepository _authRepository = Get.find();
  late final NotificationRepository _notificationRepository;

  final RxList<UserNotification> notifications = <UserNotification>[].obs;
  final RxBool isLoading = false.obs;
  final RxString currentUserId = ''.obs;

  StreamSubscription<List<UserNotification>>? _notificationsSubscription;
  StreamSubscription<User?>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeRepository();
    _setupAuthListener();
  }

  void _initializeRepository() {
    try {
      _notificationRepository = Get.find<NotificationRepository>();
    } catch (e) {
      // If NotificationRepository is not found, create a new instance
      _notificationRepository = NotificationRepository();
      Get.put(_notificationRepository);
    }
  }

  void _setupAuthListener() {
    // Listen to authentication state changes
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null && user.uid != currentUserId.value) {
        // User logged in or switched
        currentUserId.value = user.uid;
        _loadNotifications();
      } else if (user == null) {
        // User logged out
        currentUserId.value = '';
        _clearNotifications();
      }
    });
  }

  Future<void> _loadNotifications() async {
    if (currentUserId.value.isEmpty) return;

    isLoading.value = true;

    try {
      // Cancel previous subscription to prevent duplicates
      await _notificationsSubscription?.cancel();

      // Create new subscription for current user
      _notificationsSubscription = _notificationRepository
          .getUserNotificationsStream(currentUserId.value)
          .listen(
            (List<UserNotification> newNotifications) {
          // Update notifications list
          notifications.assignAll(newNotifications);
        },
        onError: (error) {
          print('❌ Error loading notifications: $error');
          Get.snackbar('Error', 'Failed to load notifications: $error');
        },
      );
    } catch (e) {
      print('❌ Error setting up notifications stream: $e');
      Get.snackbar('Error', 'Failed to setup notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _clearNotifications() {
    // Cancel subscription and clear notifications when user logs out
    _notificationsSubscription?.cancel();
    notifications.clear();
  }

  Future<void> refreshNotifications() async {
    if (currentUserId.value.isEmpty) {
      // Check if user is still authenticated
      final currentUser = _authRepository.getLoggedInUser();
      if (currentUser == null) {
        _clearNotifications();
        return;
      }
      currentUserId.value = currentUser.uid;
    }

    // Reload notifications for current user
    await _loadNotifications();

    // Add a small delay to show the refresh indicator
    await Future.delayed(const Duration(milliseconds: 500));
  }

  int get unreadNotificationsCount =>
      notifications.where((notification) => !notification.isRead).length;

  bool get hasUnreadNotifications => unreadNotificationsCount > 0;

  Future<void> markAsRead(String notificationId) async {
    if (currentUserId.value.isEmpty) return;

    try {
      await _notificationRepository.markNotificationAsRead(notificationId);
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      Get.snackbar('Error', 'Failed to mark notification as read');
    }
  }

  Future<void> markAllAsRead() async {
    if (currentUserId.value.isEmpty) return;

    try {
      await _notificationRepository.markAllNotificationsAsRead(currentUserId.value);
      Get.snackbar('Success', 'All notifications marked as read');
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
      Get.snackbar('Error', 'Failed to mark all notifications as read');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    if (currentUserId.value.isEmpty) return;

    try {
      await _notificationRepository.deleteNotification(notificationId);
      Get.snackbar('Success', 'Notification deleted');
    } catch (e) {
      print('❌ Error deleting notification: $e');
      Get.snackbar('Error', 'Failed to delete notification');
    }
  }

  Future<void> clearAllNotifications() async {
    if (currentUserId.value.isEmpty) return;

    try {
      await _notificationRepository.clearAllNotifications(currentUserId.value);
      Get.snackbar('Success', 'All notifications cleared');
    } catch (e) {
      print('❌ Error clearing notifications: $e');
      Get.snackbar('Error', 'Failed to clear notifications');
    }
  }

  void onNotificationTap(UserNotification notification) async {
    if (currentUserId.value.isEmpty) return;

    // Mark as read first
    if (!notification.isRead) {
      await markAsRead(notification.id);
    }

    // Navigate to the appropriate page based on notification type
    if (notification.applicationId != null &&
        notification.positionType != null &&
        notification.positionId != null) {
      // Navigate to application details
      Get.offAll(() => UserHomePage(), arguments: 3);
    }
  }

  @override
  void onClose() {
    // Clean up subscriptions when controller is disposed
    _notificationsSubscription?.cancel();
    _authSubscription?.cancel();
    super.onClose();
  }
}
