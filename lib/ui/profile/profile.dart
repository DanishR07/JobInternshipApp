import 'dart:io';
import 'package:final_lab/ui/profile/create_update_profile.dart'; // Assuming SaveProfilePage is here
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:final_lab/ui/profile/view_models/profile_vm.dart';
import '../../data/AuthRepository.dart'; // Ensure AuthRepository is imported
import '../../data/ProfileRepository.dart';
import '../../data/media_repository.dart';
import '../../model/profile.dart';
import '../user_home/custom_app_bar.dart';
import '../user_home/custom_drawer.dart';

class ShowProfilePage extends StatefulWidget {
  const ShowProfilePage({super.key});

  @override
  State<ShowProfilePage> createState() => _ShowProfilePageState();
}

class _ShowProfilePageState extends State<ShowProfilePage> {
  final profileViewModel = Get.find<ProfileViewModel>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    // Use the injected _authRepository here as well for consistency
    final userId = _authRepository.getLoggedInUser()?.uid;
    if (userId != null) {
      profileViewModel.getUser(userId, showNotFoundMessage: true);
    }
  }

  // --- Helper Widgets for Professional Look (no changes here) ---

  // Helper widget to build an individual profile info card
  Widget _buildProfileInfoCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xFF616161),
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build an individual resume card
  Widget _buildResumeInfoCard(String resumeUrl) {
    String fileName = resumeUrl.split('/').last;
    if (fileName.contains('?')) {
      fileName = fileName.split('?').first;
    }
    fileName = Uri.decodeComponent(fileName);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Resume',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            Flexible(
              child: TextButton.icon(
                icon: const Icon(Icons.picture_as_pdf, color: Color(0xFFD32F2F), size: 20),
                label: Text(
                  fileName,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Color(0xFF2196F3),
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: () async {
                  if (await canLaunchUrl(Uri.parse(resumeUrl))) {
                    await launchUrl(Uri.parse(resumeUrl));
                  } else {
                    Get.snackbar(
                      'Error',
                      'Could not open resume link. Please check your internet connection or the file.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build the Delete Account card
  Widget _buildDeleteAccountCard(NewUser user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Obx(() => profileViewModel.isDeleting.value
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFD32F2F)))
            : ListTile(
          title: const Text(
            'Delete Account',
            style: TextStyle(
              color: Color(0xFFD32F2F),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_forever, color: Color(0xFFD32F2F), size: 28),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, color: Color(0xFFD32F2F), size: 18),
            ],
          ),
          onTap: () {
            Get.dialog(
              AlertDialog(
                title: const Text('Confirm Delete Account', style: TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.bold)),
                content: const Text(
                  'Are you sure you want to delete your account? This action cannot be undone and will permanently remove your profile data.',
                  style: TextStyle(color: Color(0xFF616161)),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF616161)),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Get.back(); // Close the dialog
                      await profileViewModel.deleteUser(user);
                    },
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFFD32F2F)),
                    child: const Text('Yes, Delete', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              barrierDismissible: false,
            );
          },
        ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        title: 'Profile', // or any screen name

      ),
      drawer: const CustomDrawer(),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Obx(() {
        final user = profileViewModel.currentUser.value;
        final isLoading = profileViewModel.isAdding.value;

        if (isLoading && user == null) {
          return const Center(child: CircularProgressIndicator(color: Colors.black));
        }

        if (user == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off, size: 90, color: Color(0xFF9E9E9E)),
                  const SizedBox(height: 25),
                  const Text(
                    'No Profile Found!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'It looks like you haven\'t set up your profile yet. Please create one to continue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Color(0xFF616161)),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: () {
                      // --- ADDED LOGIN CHECK HERE ---
                      final currentUser = _authRepository.getLoggedInUser();
                      if (currentUser == null) {
                        Get.snackbar(
                          'Login Required',
                          'You must be logged in to create a profile.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                      } else {
                        // --- ONLY NAVIGATE if user is logged in ---
                        Get.to(() => SaveProfilePage());
                      }
                    },
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
                    label: const Text('Create My Profile', style: TextStyle(color: Colors.white, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: 40.0, bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 3,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: const Color(0xFFE0E0E0),
                        backgroundImage: user.image != null && user.image!.isNotEmpty
                            ? CachedNetworkImageProvider(user.image!) as ImageProvider
                            : null,
                        child: user.image == null || user.image!.isEmpty
                            ? const Icon(Icons.person, size: 70, color: Color(0xFFBDBDBD))
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          // --- ADDED LOGIN CHECK FOR EDIT PROFILE BUTTON TOO (OPTIONAL BUT RECOMMENDED) ---
                          final currentUser = _authRepository.getLoggedInUser();
                          if (currentUser == null) {
                            Get.snackbar(
                              'Login Required',
                              'You must be logged in to edit your profile.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                            );
                          } else {
                            Get.to(() => SaveProfilePage());
                          }
                        },
                        child: Card(
                          elevation: 6,
                          color: const Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                Text(
                  '${user.firstName} ${user.lastName}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 20),

                _buildProfileInfoCard('Email', user.email),
                _buildProfileInfoCard('Phone', user.phoneNumber),
                if (user.resume != null && user.resume!.isNotEmpty)
                  _buildResumeInfoCard(user.resume!),
                const SizedBox(height: 30),
                _buildDeleteAccountCard(user),
                const SizedBox(height: 30),
              ],
            ),
          );
        }
      }),
    );
  }
}

// Ensure the binding is defined if it's not already global
class ShowProfileBinding extends Bindings {
  @override
  void dependencies() {
    // AuthRepository should be put here if it's not globally available elsewhere
    Get.put(AuthRepository());
    Get.put(UserRepository());
    Get.put(MediaRepository());
    Get.put(ProfileViewModel());
  }
}