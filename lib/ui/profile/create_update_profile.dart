import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Add this import
import 'package:final_lab/ui/profile/view_models/profile_vm.dart'; // Corrected import
import 'package:url_launcher/url_launcher.dart';
import '../../data/AuthRepository.dart';
import '../../data/ProfileRepository.dart';
import '../../data/media_repository.dart';
import '../../model/profile.dart';

class SaveProfilePage extends StatefulWidget {
  final NewUser? existingUser; // This will become less critical as ViewModel handles current user
  SaveProfilePage({super.key, this.existingUser});

  @override
  State<SaveProfilePage> createState() => _SaveProfilePageState();
}

class _SaveProfilePageState extends State<SaveProfilePage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  late ProfileViewModel profileViewModel;

  @override
  void initState() {
    super.initState();
    profileViewModel = Get.find<ProfileViewModel>();

    // Initialize controllers from the ViewModel's currentUser if it exists,
    // otherwise use widget.existingUser as a fallback/initial data source.
    // The ViewModel's currentUser should be the single source of truth over time.
    final currentUserFromVm = profileViewModel.currentUser.value;
    final userToDisplay = currentUserFromVm ?? widget.existingUser;

    if (userToDisplay != null) {
      firstNameController.text = userToDisplay.firstName;
      lastNameController.text = userToDisplay.lastName;
      emailController.text = userToDisplay.email;
      phoneController.text = userToDisplay.phoneNumber;
      // Note: image and resume are handled by Obx and pickers, not controllers.
      // The ViewModel should manage the initial display for images/resumes.
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we are creating or updating for AppBar title and button text
    // The ViewModel's currentUser being non-null indicates an update scenario.
    final bool isUpdating = profileViewModel.currentUser.value != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isUpdating ? 'Edit Profile' : 'Create Profile',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white, // Consistent AppBar styling
        elevation: 0,
        leading: IconButton( // Added back button for navigation
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 18, bottom: 25),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isUpdating ? 'Update your information!' : 'Fill your information!',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('This information will be used for your profile.'), // Updated text
                ),
                const SizedBox(height: 10),

                // --- Profile Image Section ---
                Obx(
                      () {
                    final pickedImagePath = profileViewModel.image.value?.path;
                    final existingImageUrl = profileViewModel.currentUser.value?.image;

                    ImageProvider? backgroundImage;
                    if (pickedImagePath != null) {
                      backgroundImage = FileImage(File(pickedImagePath));
                    } else if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
                      backgroundImage = CachedNetworkImageProvider(existingImageUrl);
                    }

                    return Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: backgroundImage,
                          child: backgroundImage == null
                              ? const Icon(Icons.person, size: 40, color: Colors.grey)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: profileViewModel.pickImage,
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.black12 ,
                              child: Icon(
                                pickedImagePath != null || (existingImageUrl != null && existingImageUrl.isNotEmpty) ? Icons.edit : Icons.camera_alt,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                TextButton(
                  onPressed: () {
                    profileViewModel.pickImage();
                  },
                  child: Text(
                    isUpdating ? 'Update image' : 'Choose image',
                  ),
                ),
                const SizedBox(height: 10),

                // --- First Name / Last Name Row ---
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text(
                                'First Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 9),
                            TextFormField(
                              controller: firstNameController,
                              decoration: InputDecoration(
                                hintStyle: TextStyle(color: Color(0xFF8391A1)),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text(
                                'Last Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 9),
                            TextField(
                              cursorColor: Colors.black,
                              controller: lastNameController,
                              decoration: InputDecoration(
                                hintStyle: TextStyle(color: Color(0xFF8391A1)),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- Email ---
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Email',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                TextField(
                  cursorColor: Colors.black,
                  controller: emailController,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Color(0xFF8391A1)),
                    hintText: 'example@gmail.com',
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black, width: 0.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Phone ---
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Phone',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                TextField(
                  keyboardType: TextInputType.number,
                  cursorColor: Colors.black,
                  controller: phoneController,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Color(0xFF8391A1)),
                    hintText: '03*********',
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black, width: 0.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Added spacing

                // --- Resume PDF Section (NEW) ---
                Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Resume (PDF)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 9),
                    // Display currently selected file or existing file
                    if (profileViewModel.resumeFile.value != null)
                      Text(
                        'Selected: ${profileViewModel.resumeFile.value!.name}',
                        style: const TextStyle(color: Colors.blue),
                      )
                    else if (profileViewModel.currentUser.value?.resume != null && profileViewModel.currentUser.value!.resume!.isNotEmpty)
                      InkWell( // Use InkWell for clickable text
                        onTap: () async {
                          final resumeUrl = profileViewModel.currentUser.value!.resume!;
                          if (await canLaunchUrl(Uri.parse(resumeUrl))) {
                            await launchUrl(Uri.parse(resumeUrl));
                          } else {
                            Get.snackbar('Error', 'Could not open resume link.');
                          }
                        },
                        child: Text(
                          'Current: ${profileViewModel.currentUser.value!.resume!.split('/').last}', // Show file name from URL
                          style: const TextStyle(
                            color: Colors.pink,
                            decoration: TextDecoration.underline, // Indicate it's clickable
                          ),
                        ),
                      )
                    else
                      const Text('No resume selected.', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: profileViewModel.pickResume,
                        icon: const Icon(Icons.upload_file),
                        label: Text(
                          profileViewModel.resumeFile.value != null || (profileViewModel.currentUser.value?.resume != null && profileViewModel.currentUser.value!.resume!.isNotEmpty)
                              ? 'Change Resume'
                              : 'Upload Resume',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 40),

                // --- Save/Update Button ---
                Obx(() {
                  return profileViewModel.isAdding.value
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () async {
                      // Decide whether to add or update based on ViewModel's currentUser
                      if (profileViewModel.currentUser.value != null) {
                        await profileViewModel.updateUser(
                          firstNameController.text,
                          lastNameController.text,
                          emailController.text,
                          phoneController.text,
                        );
                      } else {
                        await profileViewModel.addUser(
                          firstNameController.text,
                          lastNameController.text,
                          emailController.text,
                          phoneController.text,
                        );
                      }
                    },
                    child: Text(
                      isUpdating ? 'Update' : 'Save',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }),

                const SizedBox(height: 20), // Padding at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SaveProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthRepository());
    Get.put(UserRepository()); // Assuming this is your main user data repository
    Get.put(MediaRepository()); // Ensure MediaRepository gets Cloudinary instance
    Get.put(ProfileViewModel());
  }
}