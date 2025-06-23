// lib/data/applied_positions_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/AppliedPositions.dart';
import '../model/Job.dart';
import '../model/Internship.dart';
import '../services/fcm_v1_service.dart';

class AppliedPositionsRepository {
  final CollectionReference _applicationsCollection =
  FirebaseFirestore.instance.collection('appliedPositions');

  Future<void> applyForJob(String userId, Job job) async {
    final querySnapshot = await _applicationsCollection
        .where('userId', isEqualTo: userId)
        .where('positionId', isEqualTo: job.id)
        .where('positionType', isEqualTo: 'job')
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      throw Exception('You have already applied for this job.');
    }

    final newAppliedPosition = AppliedPosition(
      id: _applicationsCollection.doc().id,
      userId: userId,
      positionId: job.id,
      positionType: 'job',
      appliedDate: DateTime.now(),
      status: 'Pending',
    );

    await _applicationsCollection.doc(newAppliedPosition.id).set(newAppliedPosition.toMap());
  }

  Future<void> applyForInternship(String userId, Internship internship) async {
    final querySnapshot = await _applicationsCollection
        .where('userId', isEqualTo: userId)
        .where('positionId', isEqualTo: internship.id)
        .where('positionType', isEqualTo: 'internship')
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      throw Exception('You have already applied for this internship.');
    }

    final newAppliedPosition = AppliedPosition(
      id: _applicationsCollection.doc().id,
      userId: userId,
      positionId: internship.id,
      positionType: 'internship',
      appliedDate: DateTime.now(),
      status: 'Pending',
    );

    await _applicationsCollection.doc(newAppliedPosition.id).set(newAppliedPosition.toMap());
  }

  Stream<List<AppliedPosition>> getAppliedPositionsStream(String userId) {
    return _applicationsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('appliedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => AppliedPosition.fromFirestore(doc))
        .toList());
  }

  Future<bool> hasUserApplied(String userId, String positionId, String positionType) async {
    try {
      final querySnapshot = await _applicationsCollection
          .where('userId', isEqualTo: userId)
          .where('positionId', isEqualTo: positionId)
          .where('positionType', isEqualTo: positionType)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if user applied for position: $e');
      return false;
    }
  }

  Stream<List<AppliedPosition>> getAllAppliedPositionsStream() {
    return _applicationsCollection
        .orderBy('appliedDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => AppliedPosition.fromFirestore(doc))
        .toList());
  }

  // 🚀 ENHANCED: Update application status with FCM V1 notification
  Future<void> updateApplicationStatus(String appliedPositionId, String newStatus) async {
    try {
      print('🔄 Updating application status...');
      print('📋 Application ID: $appliedPositionId');
      print('📊 New Status: $newStatus');

      // Get the application details first
      final applicationDoc = await _applicationsCollection.doc(appliedPositionId).get();

      if (!applicationDoc.exists) {
        throw Exception('Application not found');
      }

      final applicationData = applicationDoc.data() as Map<String, dynamic>;
      final userId = applicationData['userId'] as String;
      final positionId = applicationData['positionId'] as String;
      final positionType = applicationData['positionType'] as String;

      print('👤 User ID: $userId');
      print('💼 Position ID: $positionId');
      print('📝 Position Type: $positionType');

      // Update the status in Firestore
      await _applicationsCollection.doc(appliedPositionId).update({'status': newStatus});
      print('✅ Status updated in Firestore');

      // Get position details for notification
      String positionTitle = 'Position';
      String companyName = 'Company';

      try {
        if (positionType == 'job') {
          final jobDoc = await FirebaseFirestore.instance
              .collection('jobs')
              .doc(positionId)
              .get();
          if (jobDoc.exists) {
            final jobData = jobDoc.data()!;
            positionTitle = jobData['jobtitle'] ?? 'Job Position';
            companyName = jobData['companyname'] ?? 'Company';
          }
        } else if (positionType == 'internship') {
          final internshipDoc = await FirebaseFirestore.instance
              .collection('internships')
              .doc(positionId)
              .get();
          if (internshipDoc.exists) {
            final internshipData = internshipDoc.data()!;
            positionTitle = internshipData['title'] ?? 'Internship Position';
            companyName = internshipData['companyName'] ?? 'Company';
          }
        }
      } catch (e) {
        print('⚠️ Could not fetch position details: $e');
      }

      print('📢 Sending FCM V1 notification...');
      print('💼 Position: $positionTitle at $companyName');

      // ✅ Send FCM V1 notification
      final notificationSent = await FCMV1Service.sendApplicationStatusNotification(
        userId: userId,
        applicationId: appliedPositionId,
        positionType: positionType, // Added missing parameter
        positionId: positionId,     // Added missing parameter
        positionTitle: positionTitle,
        companyName: companyName,
        newStatus: newStatus,
      );

      if (notificationSent) {
        print('✅ FCM V1 notification sent successfully');
      } else {
        print('❌ Failed to send FCM V1 notification');
      }

    } catch (e) {
      print('❌ Error updating application status: $e');
      throw Exception('Failed to update application status: $e');
    }
  }

  // Method to delete/cancel an application
  Future<void> deleteApplication(String appliedPositionId) async {
    try {
      await _applicationsCollection.doc(appliedPositionId).delete();
    } catch (e) {
      throw Exception('Failed to delete application: $e');
    }
  }
}