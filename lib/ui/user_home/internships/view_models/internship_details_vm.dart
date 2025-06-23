import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:final_lab/data/ProfileRepository.dart'; // Import your UserRepository

import '../../../../data/AuthRepository.dart';
import '../../../../data/applied_positions_repository.dart';
import '../../../../model/Internship.dart'; // Corrected import for Internship model

class InternshipDetailsViewModel extends GetxController {
  final AuthRepository _authRepository = Get.find();
  final AppliedPositionsRepository _appliedPositionsRepository = Get.find();
  final UserRepository _userRepository = Get.find(); // Inject UserRepository

  var hasUserApplied = false.obs;

  Future<void> checkApplicationStatus(Internship internship) async {
    final currentUser = _authRepository.getLoggedInUser();
    if (currentUser != null) {
      hasUserApplied.value = await _appliedPositionsRepository.hasUserApplied(currentUser.uid, internship.id, 'internship');
    } else {
      hasUserApplied.value = false;
    }
  }

  Future<void> applyForInternship(Internship internship) async {
    final currentUser = _authRepository.getLoggedInUser();
    if (currentUser == null) {
      Get.snackbar(
        'Error',
        'You must be logged in to apply for internships.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    // --- NEW PROFILE CHECK LOGIC ---
    final userInternalId = currentUser.uid; // Get the Firebase Auth UID
    final profileExists = await _userRepository.hasUserProfile(userInternalId);

    if (!profileExists) {
      Get.snackbar(
        'Profile Required',
        'Please complete your profile before applying for internships.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      // Optionally navigate to profile creation page
      // Get.toNamed('/create_profile'); // Assuming you have a route for this
      return;
    }
    // --- END NEW PROFILE CHECK LOGIC ---

    try {
      await _appliedPositionsRepository.applyForInternship(currentUser.uid, internship);
      hasUserApplied.value = true;
      Get.snackbar(
        'Success',
        'Application for ${internship.title} submitted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Apply for internship error: $e');
      Get.snackbar(
        'Application Failed',
        e.toString().contains('already applied')
            ? 'You have already applied for this internship.'
            : 'Failed to submit application: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}