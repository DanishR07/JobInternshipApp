// lib/ui/applications/view_models/applied_positions_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../data/AuthRepository.dart';
import '../../../../data/applied_positions_repository.dart';
import '../../../../data/internships_repository.dart';
import '../../../../data/jobs_repository.dart';
import '../../../../model/AppliedPositions.dart'; // To get the current user


class AppliedPositionsViewModel extends GetxController {
  final AuthRepository _authRepository = Get.find();
  final AppliedPositionsRepository _appliedPositionsRepository = Get.find();
  final JobsRepository _jobsRepository = Get.find();
  final InternshipsRepository _internshipsRepository = Get.find();

  Rxn<User> currentUser = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _authRepository.getLoggedInUser();
  }

  Stream<List<AppliedPosition>> get appliedPositionsStream {
    final userId = currentUser.value?.uid;
    if (userId == null) {
      // If no user is logged in, return an empty stream
      return Stream.value([]);
    }
    return _appliedPositionsRepository.getAppliedPositionsStream(userId);
  }

  Stream<dynamic> getPositionDetailsStream(String positionId, String positionType) {
    if (positionType == 'job') {
      return _jobsRepository.getJobStreamById(positionId);
    } else { // internship
      return _internshipsRepository.getinternshipstreamById(positionId);
    }
  }

  Future<void> deleteApplication(String appliedPositionId) async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await _appliedPositionsRepository.deleteApplication(appliedPositionId);

      Get.back(); // Dismiss loading indicator
      Get.snackbar(
        'Success',
        'Application deleted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back(); // Dismiss loading indicator
      Get.snackbar(
        'Error',
        'Failed to delete application: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

}