import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:final_lab/data/ProfileRepository.dart'; // Import your UserRepository

import '../../../../data/AuthRepository.dart';
import '../../../../data/applied_positions_repository.dart';
import '../../../../model/Job.dart';

class JobDetailsViewModel extends GetxController {
  final AuthRepository _authRepository = Get.find();
  final AppliedPositionsRepository _appliedPositionsRepository = Get.find();
  final UserRepository _userRepository = Get.find(); // Inject UserRepository

  var hasUserApplied = false.obs;

  Future<void> checkApplicationStatus(Job job) async {
    final currentUser = _authRepository.getLoggedInUser();
    if (currentUser != null) {
      hasUserApplied.value = await _appliedPositionsRepository.hasUserApplied(
          currentUser.uid, job.id, 'job');
    } else {
      hasUserApplied.value = false;
    }
  }

  Future<void> applyForJob(Job job) async {
    final currentUser = _authRepository.getLoggedInUser();
    if (currentUser == null) {
      Get.snackbar(
        'Error',
        'You must be logged in to apply for jobs.',
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
        'Please complete your profile before applying for jobs.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }
    // --- END NEW PROFILE CHECK LOGIC ---

    try {
      await _appliedPositionsRepository.applyForJob(currentUser.uid, job);
      hasUserApplied.value = true;
      Get.snackbar(
        'Success',
        'Application for ${job.jobtitle} submitted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Apply for job error: $e');
      Get.snackbar(
        'Application Failed',
        e.toString().contains('already applied')
            ? 'You have already applied for this job.'
            : 'Failed to submit application: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}