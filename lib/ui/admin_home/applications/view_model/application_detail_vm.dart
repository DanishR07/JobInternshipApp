import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:final_lab/data/ProfileRepository.dart';
import '../../../../data/applied_positions_repository.dart';
import '../../../../data/internships_repository.dart';
import '../../../../data/jobs_repository.dart';
import '../../../../data/notification_repository.dart';
import '../../../../model/AppliedPositions.dart';
import '../../../../model/profile.dart';
import '../../../../model/Job.dart';
import '../../../../model/Internship.dart';

class ApplicationDetailViewModel extends GetxController {
  final AppliedPositionsRepository _appliedPositionsRepository = Get.find();
  final JobsRepository _jobsRepository = Get.find();
  final InternshipsRepository _internshipsRepository = Get.find();
  final UserRepository _profileRepository = Get.find();
  late final NotificationRepository _notificationRepository;

  final Rx<AppliedPosition?> appliedPosition = Rxn<AppliedPosition>();
  final Rx<dynamic> positionDetails = Rxn<dynamic>();
  final Rx<NewUser?> applicantProfile = Rxn<NewUser>();
  final RxBool isLoading = false.obs;
  final RxString currentStatus = ''.obs;
  final RxBool isNotificationSending = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeRepository();
    if (Get.arguments != null && Get.arguments is AppliedPosition) {
      appliedPosition.value = Get.arguments as AppliedPosition;
      currentStatus.value = appliedPosition.value!.status;
      _fetchDetails();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar('Error', 'No application data received.', snackPosition: SnackPosition.BOTTOM);
      });
    }
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

  Future<void> _fetchDetails() async {
    isLoading.value = true;
    try {
      if (appliedPosition.value == null) return;

      if (appliedPosition.value!.positionType == 'job') {
        positionDetails.bindStream(_jobsRepository.getJobStreamById(appliedPosition.value!.positionId));
      } else {
        positionDetails.bindStream(_internshipsRepository.getinternshipstreamById(appliedPosition.value!.positionId));
      }

      final applicantUserId = appliedPosition.value!.userId;

      if (applicantUserId.isNotEmpty) {
        applicantProfile.bindStream(_profileRepository.getUserStream(applicantUserId));
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar('Error', 'Applicant User ID is empty.', snackPosition: SnackPosition.BOTTOM);
        });
        applicantProfile.value = null;
      }

    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar('Error', 'Failed to load details: $e', snackPosition: SnackPosition.BOTTOM);
      });
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateApplicationStatus() async {
    if (appliedPosition.value == null) return;

    isLoading.value = true;
    try {
      // Only create notification if status is actually changing
      final oldStatus = appliedPosition.value!.status;
      if (oldStatus != currentStatus.value) {
        print('🔄 Updating application status from $oldStatus to ${currentStatus.value}');

        // Update the application status in Firestore
        print('🔄 Updating application status...');
        print('📋 Application ID: ${appliedPosition.value!.id}');
        print('📊 New Status: ${currentStatus.value}');
        print('👤 User ID: ${appliedPosition.value!.userId}');
        print('💼 Position ID: ${appliedPosition.value!.positionId}');
        print('📝 Position Type: ${appliedPosition.value!.positionType}');

        try {
          // First update the status in Firestore
          await _appliedPositionsRepository.updateApplicationStatus(
            appliedPosition.value!.id,
            currentStatus.value,
          );

          print('✅ Status updated in Firestore');
        } catch (e) {
          print('❌ Error updating status in Firestore: $e');
          throw e;
        }

        // Create notification for the user
        if (positionDetails.value != null && applicantProfile.value != null) {
          String positionTitle = '';
          String companyName = '';

          if (appliedPosition.value!.positionType == 'job') {
            Job job = positionDetails.value as Job;
            positionTitle = job.jobtitle;
            companyName = job.companyname;
          } else {
            Internship internship = positionDetails.value as Internship;
            positionTitle = internship.title;
            companyName = internship.companyName;
          }

          print('📧 Creating notification for user...');
          print('👤 User ID: ${appliedPosition.value!.userId}');
          print('📋 Application ID: ${appliedPosition.value!.id}');
          print('💼 Position: $positionTitle at $companyName');
          print('📊 Status: ${currentStatus.value}');

          try {
            await _notificationRepository.createStatusUpdateNotification(
              userId: appliedPosition.value!.userId,
              applicationId: appliedPosition.value!.id,
              positionType: appliedPosition.value!.positionType,
              positionId: appliedPosition.value!.positionId,
              positionTitle: positionTitle,
              companyName: companyName,
              newStatus: currentStatus.value,
            );
            print('✅ In-app notification created successfully');

            // Debug: Check user's notifications
            await _notificationRepository.debugUserNotifications(appliedPosition.value!.userId);

          } catch (e) {
            print('❌ Error creating in-app notification: $e');
            // Continue even if notification creation fails
            // The status update is more important
          }
        } else {
          print('⚠️ Missing position details or applicant profile, skipping notification');
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.back();
          Get.snackbar(
              'Success',
              'Application status updated to ${currentStatus.value}!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white
          );
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.back();
          Get.snackbar(
              'Info',
              'Status unchanged',
              snackPosition: SnackPosition.BOTTOM
          );
        });
      }
    } catch (e) {
      print('❌ Error updating application status: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
            'Error',
            'Failed to update status: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white
        );
      });
    } finally {
      isLoading.value = false;
    }
  }

  void setSelectedStatus(String? newStatus) {
    if (newStatus != null) {
      currentStatus.value = newStatus;
    }
  }
}
