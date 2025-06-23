import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../data/AuthRepository.dart';
import '../profile/view_models/profile_vm.dart';
import '../user_home/user_home.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthRepository _authRepository = Get.find<AuthRepository>();

    final ProfileViewModel _profileViewModel = Get.find<ProfileViewModel>();

    return Obx(() {
      final currentUser = _authRepository.getLoggedInUser();
      final userProfile = _profileViewModel.currentUser.value;
      final isLoggedIn = currentUser != null;

      String displayName = "Guest User";
      String displayEmail = "Not logged in";
      String? profileImageUrl;

      if (isLoggedIn) {
        displayName =
            "${userProfile?.firstName ?? 'User'} ${userProfile?.lastName ?? ''}";
        displayEmail = userProfile?.email ?? currentUser.email ?? 'No email';
        profileImageUrl = userProfile?.image;
      }

      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(displayEmail),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage:
                    profileImageUrl != null && profileImageUrl.isNotEmpty
                        ? CachedNetworkImageProvider(profileImageUrl)
                        : null,
                child:
                    profileImageUrl == null || profileImageUrl.isEmpty
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
              ),
              decoration: const BoxDecoration(color: Color(0xFF1E232C)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Get.offAll(() => const UserHomePage(), arguments: 0),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () => Get.offAll(() => const UserHomePage(), arguments: 4),
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('Jobs'),
              onTap: () => Get.offAll(() => const UserHomePage(), arguments: 1),
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Internships'),
              onTap: () => Get.offAll(() => const UserHomePage(), arguments: 2),
            ),
            ListTile(
              leading: const Icon(Icons.history_outlined),
              title: const Text('Applied Positions'),
              onTap: () {
                Get.back();
                Get.offAll(() => UserHomePage(), arguments: 3);
              },
            ),
            const Divider(),

            // Auth Section
            if (!isLoggedIn)
              ListTile(
                leading: Icon(Icons.login_rounded),
                title: Text('Login / Register'),
                onTap: () {
                  Get.back();
                  Get.offAllNamed('/welcome');
                },
                iconColor: Colors.blue,
              )
            else
              ListTile(
                leading: Icon(Icons.logout_rounded),
                title: Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Logout Confirmation'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Get.back(); // Close the dialog
                          },
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Get.back(); // Close the dialog
                            await _authRepository.logout();
                            Get.offAllNamed('/login');

                            // Modern snackbar
                            Get.snackbar(
                              '',
                              '',
                              titleText: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Logged Out Successfully',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              messageText: const Text(
                                'You have been logged out successfully.',
                                style: TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: const Color(0xFF1E232C),
                              borderRadius: 15,
                              margin: const EdgeInsets.all(16),
                              duration: const Duration(seconds: 3),
                              boxShadows: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            );

                          },

                          child: const Text('Yes', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                },
                iconColor: Colors.red,
              ),

            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }
}
