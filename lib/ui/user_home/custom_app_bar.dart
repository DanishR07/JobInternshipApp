import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/AuthRepository.dart';
import '../../data/notification_repository.dart';
import '../profile/view_models/profile_vm.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String? title; // null means HomePage, non-null means other page

  const CustomAppBar({
    Key? key,
    required this.scaffoldKey,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthRepository _authRepository = Get.find<AuthRepository>();
    final ProfileViewModel _profileViewModel = Get.find<ProfileViewModel>();
    final NotificationRepository _notificationRepository = Get.find<NotificationRepository>();

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: GestureDetector(
        onTap: () {
          scaffoldKey.currentState?.openDrawer();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Obx(() {
            final userProfile = _profileViewModel.currentUser.value;
            final isLoggedIn = _authRepository.getLoggedInUser() != null;

            if (isLoggedIn &&
                userProfile?.image != null &&
                userProfile!.image!.isNotEmpty) {
              return CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(userProfile.image!),
                radius: 15,
              );
            } else {
              return const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white),
                radius: 15,
              );
            }
          }),
        ),
      ),
      centerTitle: true,
      title: title == null
          ? Image.asset("assets/logo.png", height: 40)
          : Text(
        title!,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        StreamBuilder<int>(
            stream: getUnreadNotificationCountStream(_authRepository),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;

              return IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_outlined, color: Colors.black87),
                    if (count > 0)
                      Positioned(
                        right: -5,
                        top: -5,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            count > 9 ? '9+' : count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  final currentUser = _authRepository.getLoggedInUser();
                  if (currentUser != null) {
                    Get.toNamed('/notifications');
                  } else {
                    Get.snackbar(
                      'Login Required',
                      'Please log in to view notifications',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
              );
            }
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // Get unread notifications count stream with proper user check
  Stream<int> getUnreadNotificationCountStream(AuthRepository authRepository) {
    final currentUser = authRepository.getLoggedInUser();
    if (currentUser == null) {
      return Stream.value(0); // Return empty stream if no user is logged in
    }

    try {
      final NotificationRepository notificationRepository = Get.find<NotificationRepository>();
      return notificationRepository.getUnreadNotificationCountStream(currentUser.uid);
    } catch (e) {
      print('Error getting notification repository: $e');
      return Stream.value(0);
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
