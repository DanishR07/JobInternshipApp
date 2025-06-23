import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async'; // Import for StreamSubscription

import '../../../data/AuthRepository.dart';
import '../../../data/applied_positions_repository.dart';
import '../../../data/jobs_repository.dart';
import '../../../data/internships_repository.dart';

import '../../../model/AppliedPositions.dart';
import '../../auth/view_models/login_vm.dart';

class AppliedPositionsViewModel extends GetxController {
  final AuthRepository _authRepository = Get.find();
  final AppliedPositionsRepository _appliedPositionsRepository = Get.find();
  final JobsRepository _jobsRepository = Get.find();
  final InternshipsRepository _internshipsRepository = Get.find();
  final LoginViewModel _loginViewModel = Get.find();

  Rxn<User> currentUser = Rxn<User>();
  RxBool isAdmin = false.obs;

  final _applicationsSubject = BehaviorSubject<List<AppliedPosition>>();
  // Store the active subscription to the source stream
  StreamSubscription<List<AppliedPosition>>? _currentApplicationsSubscription;

  Stream<List<AppliedPosition>> get appliedPositionsStream => _applicationsSubject.stream;

  @override
  void onInit() {
    super.onInit();
    currentUser.value = _authRepository.getLoggedInUser();

    // Listen to currentUser changes
    currentUser.listen((user) {
      _checkAdminStatus();
      _updateApplicationsStream();
    });

    // Listen to isAdmin changes
    isAdmin.listen((_) {
      _updateApplicationsStream();
    });

    // Initial call to set up the stream when the ViewModel starts
    _checkAdminStatus(); // Initial check for admin status
    _updateApplicationsStream(); // Initial stream update
  }

  void _checkAdminStatus() {
    final user = currentUser.value;
    if (user != null && user.email == 'danishriasat792@gmail.com') {
      isAdmin.value = true;
    } else {
      isAdmin.value = false;
    }
  }

  void _updateApplicationsStream() {
    // 1. Cancel the previous subscription if it exists
    _currentApplicationsSubscription?.cancel();
    _currentApplicationsSubscription = null; // Clear it to avoid stale references

    final user = currentUser.value;
    Stream<List<AppliedPosition>> sourceStream;

    if (user == null) {
      sourceStream = Stream.value([]); // Emit an empty list if no user
    } else if (isAdmin.value) {
      sourceStream = _appliedPositionsRepository.getAllAppliedPositionsStream();
    } else {
      sourceStream = _appliedPositionsRepository.getAppliedPositionsStream(user.uid);
    }

    // 2. Subscribe to the new source stream and pipe events to the BehaviorSubject
    _currentApplicationsSubscription = sourceStream.listen(
          (data) {
        // Only add if not already in the process of adding from another stream
        if (!_applicationsSubject.isClosed) {
          _applicationsSubject.add(data);
        }
      },
      onError: (error) {
        print('Error in source stream: $error');
        if (!_applicationsSubject.isClosed) {
          _applicationsSubject.addError(error);
        }
      },
      onDone: () {
        // Optionally handle when the source stream completes,
        // though for Firestore snapshots, they typically don't complete.
      },
    );
  }

  Stream<dynamic> getPositionDetailsStream(String positionId, String positionType) {
    if (positionType == 'job') {
      return _jobsRepository.getJobStreamById(positionId);
    } else {
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


  // Method to cancel an application
  Future<void> cancelApplication(AppliedPosition appliedPosition) async {
    try {
      await _appliedPositionsRepository.deleteApplication(appliedPosition.id);
    } catch (e) {
      throw Exception('Failed to cancel application: $e');
    }
  }

  @override
  void onClose() {
    // Crucial: Close the BehaviorSubject and cancel the active subscription
    // to prevent memory leaks when the ViewModel is no longer in use.
    _currentApplicationsSubscription?.cancel();
    _applicationsSubject.close();
    super.onClose();
  }
}
