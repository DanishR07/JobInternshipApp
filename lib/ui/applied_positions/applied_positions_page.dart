import 'package:final_lab/data/ProfileRepository.dart';
import 'package:final_lab/data/media_repository.dart';
import 'package:final_lab/ui/applied_positions/view_model/applied_positions_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../../../data/AuthRepository.dart';
import '../../../data/applied_positions_repository.dart';
import '../../../data/internships_repository.dart';
import '../../../data/jobs_repository.dart';
import '../../../model/AppliedPositions.dart';
import '../../../model/Job.dart';
import '../../../model/Internship.dart';
import '../auth/view_models/login_vm.dart';
import '../profile/view_models/profile_vm.dart';
import '../user_home/custom_app_bar.dart';
import '../user_home/custom_drawer.dart';

// Change to GetView and specify the ViewModel
class AppliedPositionsPage extends GetView<AppliedPositionsViewModel> {
  AppliedPositionsPage({super.key});

  // Helper method to get color based on status (purely UI logic, stays here)
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'reviewed':
        return Colors.blue;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  final profileViewModel = Get.find<ProfileViewModel>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Method to show cancel application dialog
  void _showCancelApplicationDialog(BuildContext context, AppliedPosition appliedPosition, String title) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Application'),
        content: Text('Are you sure you want to cancel your application for "$title"?'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              _cancelApplication(appliedPosition, title);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
            },
            child: const Text('No'),
          ),
        ],
      ),
    );
  }

  // Method to cancel the application
  void _cancelApplication(AppliedPosition appliedPosition, String title) async {
    try {
      await controller.cancelApplication(appliedPosition);
      Get.snackbar(
        'Application Cancelled',
        'Your application for "$title" has been cancelled successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel application: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentUser = controller.currentUser.value;

      if (currentUser == null) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: CustomAppBar(
            scaffoldKey: _scaffoldKey,
            title: 'Applied Positions', // or any screen name
          ),
          drawer: const CustomDrawer(),
          body: const Center(
            child: Text('Please log in to view your applied positions.'),
          ),
        );
      }

      return Scaffold(
        key: _scaffoldKey,
        appBar: CustomAppBar(
          scaffoldKey: _scaffoldKey,
          title: 'Applied Positions', // or any screen name
        ),
        drawer: const CustomDrawer(),
        body: StreamBuilder<List<AppliedPosition>>(
          // Use the stream exposed by the ViewModel
          stream: controller.appliedPositionsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No positions applied yet.'));
            }

            final appliedPositions = snapshot.data!;

            return ListView.builder(
              itemCount: appliedPositions.length,
              itemBuilder: (context, index) {
                final appliedPosition = appliedPositions[index];

                return StreamBuilder<dynamic>(
                  // Use the ViewModel method to get the specific position details stream
                  stream: controller.getPositionDetailsStream(
                    appliedPosition.positionId,
                    appliedPosition.positionType,
                  ),
                  builder: (context, detailSnapshot) {
                    String title = 'Loading...';
                    String companyName = 'Loading...';
                    String salaryStipend = '';
                    IconData positionIcon = Icons.help_outline;
                    Widget imageWidget = const Icon(Icons.business, size: 40, color: Colors.grey);

                    if (detailSnapshot.connectionState == ConnectionState.waiting) {
                      title = 'Loading details...';
                      companyName = 'Loading...';
                      salaryStipend = '';
                      positionIcon = Icons.hourglass_empty;
                    } else if (detailSnapshot.hasError) {
                      title = 'Error loading details';
                      companyName = 'N/A';
                      salaryStipend = '';
                      positionIcon = Icons.error_outline;
                    } else if (detailSnapshot.hasData && detailSnapshot.data != null) {
                      if (appliedPosition.positionType == 'job') {
                        Job job = detailSnapshot.data as Job;
                        title = job.jobtitle;
                        companyName = job.companyname;
                        salaryStipend = 'Salary: ${job.salary}';
                        positionIcon = Icons.work;
                        if (job.image != null && job.image!.isNotEmpty) {
                          imageWidget = ClipOval(
                            child: Image.network(
                              job.image!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, size: 40, color: Colors.grey),
                            ),
                          );
                        }
                      } else { // internship
                        Internship internship = detailSnapshot.data as Internship;
                        title = internship.title;
                        companyName = internship.companyName;
                        salaryStipend = 'Stipend: ${internship.stipend} (${internship.duration})';
                        positionIcon = Icons.lightbulb;
                        if (internship.image != null && internship.image!.isNotEmpty) {
                          imageWidget = ClipOval(
                            child: Image.network(
                              internship.image!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.business_center, size: 40, color: Colors.grey),
                            ),
                          );
                        }
                      }
                    } else {
                      title = 'Position Deleted';
                      companyName = 'N/A';
                      salaryStipend = '';
                      positionIcon = Icons.delete_forever;
                    }

                    return InkWell(
                      onLongPress: () {
                        // Only allow cancellation if the application is still pending
                        if (appliedPosition.status.toLowerCase() == 'pending') {
                          _showCancelApplicationDialog(context, appliedPosition, title);
                        } else {
                          Get.snackbar(
                            'Cannot Cancel',
                            'You can only cancel applications that are still pending.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.orange,
                            colorText: Colors.white,
                          );
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  imageWidget,
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          companyName,
                                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Chip(
                                              avatar: Icon(
                                                positionIcon,
                                                size: 12,
                                                color: appliedPosition.positionType == 'job'
                                                    ? Colors.deepPurple
                                                    : Colors.teal,
                                              ),
                                              label: Text(
                                                appliedPosition.positionType == 'job' ? 'Job' : 'Internship',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: appliedPosition.positionType == 'job'
                                                      ? Colors.deepPurple
                                                      : Colors.teal,
                                                ),
                                              ),
                                              backgroundColor: appliedPosition.positionType == 'job'
                                                  ? Colors.deepPurple[50]
                                                  : Colors.teal[50],
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                                side: BorderSide(
                                                  color: appliedPosition.positionType == 'job'
                                                      ? Colors.deepPurple[200]!
                                                      : Colors.teal[200]!,
                                                  width: 0.8,
                                                ),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                            ),
                                            // Add a hint for long press if status is pending
                                            if (appliedPosition.status.toLowerCase() == 'pending') ...[
                                              const SizedBox(width: 8),
                                              const Icon(
                                                Icons.touch_app,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const Text(
                                                'Long press to cancel',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20, thickness: 1),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Applied On:',
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                        Text(
                                          DateFormat('MMM dd,EEEE').format(appliedPosition.appliedDate),
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          salaryStipend,
                                          style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'Status:',
                                        style: TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(appliedPosition.status).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          appliedPosition.status,
                                          style: TextStyle(
                                            color: _getStatusColor(appliedPosition.status),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      );
    }); // End of Obx
  }
}

class AppliedPositionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthRepository());
    Get.put(AppliedPositionsRepository());
    Get.put(JobsRepository());
    Get.put(InternshipsRepository());
    Get.put(MediaRepository());
    Get.put(UserRepository());
    Get.put(LoginViewModel());
    Get.put(AppliedPositionsViewModel());
    Get.put(ProfileViewModel());
  }
}
