import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For date formatting

// Assuming these imports are correct based on your project structure
import '../../../data/AuthRepository.dart';
import '../../../data/applied_positions_repository.dart';
import '../../../data/internships_repository.dart';
import '../../../data/jobs_repository.dart';
import '../../../data/ProfileRepository.dart'; // Renamed to UserRepository based on your Binding
import '../../../model/AppliedPositions.dart';
import '../../../model/Job.dart';
import '../../../model/Internship.dart';
import '../../applied_positions/view_model/applied_positions_vm.dart';
import '../../auth/view_models/login_vm.dart';
import 'applications_detail.dart';

final AuthRepository authRepository = Get.find();

// Change to GetView and specify the ViewModel
class ApplicationsPage extends GetView<AppliedPositionsViewModel> {
  const ApplicationsPage({super.key});

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

  Future<void> _confirmLogout() async {
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

              await authRepository.logout(); // Perform logout from the database

              Get.offAllNamed('/login'); // Navigate to login screen
            },

            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ✨ NEW METHOD: Show delete/cancel options on long press ✨
  void _showDeleteOptions(
    BuildContext context,
    AppliedPosition appliedPosition,
  ) {
    Get.bottomSheet(
      Card(
        margin: const EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text(
                'Delete Application',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Get.back(); // Close the bottom sheet
                _confirmAndDeleteApplication(context, appliedPosition);
              },
            ),
            const Divider(height: 0),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.grey),
              title: const Text('Cancel'),
              onTap: () {
                Get.back(); // Close the bottom sheet
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent, // Make background transparent
      elevation: 0, // No shadow for the bottom sheet itself
      isDismissible: true, // Allow dismissing by tapping outside
    );
  }

  // ✨ NEW METHOD: Show confirmation dialog and handle deletion ✨
  void _confirmAndDeleteApplication(
    BuildContext context,
    AppliedPosition appliedPosition,
  ) {
    Get.defaultDialog(
      title: 'Confirm Deletion',
      middleText:
          'Are you sure you want to delete this application? This action cannot be undone.',
      backgroundColor: Get.theme.cardColor,
      titleStyle: TextStyle(color: Get.theme.textTheme.headlineLarge?.color),
      middleTextStyle: TextStyle(color: Get.theme.textTheme.bodyMedium?.color),
      radius: 10,
      actions: [
        TextButton(
          onPressed: () {
            Get.back(); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back(); // Close the dialog
            // ✨ Call the ViewModel to handle the actual deletion ✨
            controller.deleteApplication(appliedPosition.id);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                Colors.red, // Background color for the delete button
            foregroundColor: Colors.white, // Text color
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentUser = controller.currentUser.value;

      if (currentUser == null) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            title: Row(
              children: [
                Image.asset(
                  'assets/logo.png', // Add your logo image in the assets folder
                  height: 40,
                ),
                const SizedBox(width: 70),
                Center(
                  child: const Text(
                    'Applications',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.black87),

                onPressed: _confirmLogout, // Call the confirmation function
              ),

              const SizedBox(width: 10),
            ],
          ),
          body: const Center(
            child: Text('Please log in to view your applied positions.'),
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: Row(
            children: [
              Image.asset(
                'assets/logo.png', // Add your logo image in the assets folder
                height: 40,
              ),
              const SizedBox(width: 70),
              Center(
                child: const Text(
                  'Applications',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.black87),

              onPressed: _confirmLogout, // Call the confirmation function
            ),

            const SizedBox(width: 10),
          ],
        ),
        body: StreamBuilder<List<AppliedPosition>>(
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
                  stream: controller.getPositionDetailsStream(
                    appliedPosition.positionId,
                    appliedPosition.positionType,
                  ),
                  builder: (context, detailSnapshot) {
                    String title = 'Loading...';
                    String companyName = 'Loading...';
                    String salaryStipend = '';
                    IconData positionIcon = Icons.help_outline;
                    Widget imageWidget = const Icon(
                      Icons.business,
                      size: 40,
                      color: Colors.grey,
                    );

                    if (detailSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      title = 'Loading details...';
                      companyName = 'Loading...';
                      salaryStipend = '';
                      positionIcon = Icons.hourglass_empty;
                    } else if (detailSnapshot.hasError) {
                      title = 'Error loading details';
                      companyName = 'N/A';
                      salaryStipend = '';
                      positionIcon = Icons.error_outline;
                    } else if (detailSnapshot.hasData &&
                        detailSnapshot.data != null) {
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
                              errorBuilder:
                                  (context, error, stackTrace) => const Icon(
                                    Icons.business,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                            ),
                          );
                        }
                      } else {
                        // internship
                        Internship internship =
                            detailSnapshot.data as Internship;
                        title = internship.title;
                        companyName = internship.companyName;
                        salaryStipend =
                            'Stipend: ${internship.stipend} (${internship.duration})';
                        positionIcon = Icons.lightbulb;
                        if (internship.image != null &&
                            internship.image!.isNotEmpty) {
                          imageWidget = ClipOval(
                            child: Image.network(
                              internship.image!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => const Icon(
                                    Icons.business_center,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
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

                    // Wrap the Card with InkWell for onTap
                    return InkWell(
                      onTap: () {
                        // Navigate to the detail page, passing the appliedPosition object
                        Get.to(
                          () => const ApplicationDetailPage(),
                          arguments: appliedPosition,
                          binding: ApplicationDetailBinding(),
                        );
                      },
                      // ✨ ADD THIS onLongPress CALLBACK ✨
                      onLongPress:
                          () => _showDeleteOptions(context, appliedPosition),
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[700],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Chip(
                                          avatar: Icon(
                                            positionIcon,
                                            size: 12,
                                            color:
                                                appliedPosition.positionType ==
                                                        'job'
                                                    ? Colors.deepPurple
                                                    : Colors.teal,
                                          ),
                                          label: Text(
                                            appliedPosition.positionType ==
                                                    'job'
                                                ? 'Job'
                                                : 'Internship',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  appliedPosition
                                                              .positionType ==
                                                          'job'
                                                      ? Colors.deepPurple
                                                      : Colors.teal,
                                            ),
                                          ),
                                          backgroundColor:
                                              appliedPosition.positionType ==
                                                      'job'
                                                  ? Colors.deepPurple[50]
                                                  : Colors.teal[50],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            side: BorderSide(
                                              color:
                                                  appliedPosition
                                                              .positionType ==
                                                          'job'
                                                      ? Colors.deepPurple[200]!
                                                      : Colors.teal[200]!,
                                              width: 0.8,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20, thickness: 1),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Applied On:',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          DateFormat(
                                            'MMM dd,EEEE',
                                          ).format(appliedPosition.appliedDate),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          salaryStipend,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.green,
                                            fontWeight: FontWeight.w500,
                                          ),
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
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(
                                            appliedPosition.status,
                                          ).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        child: Text(
                                          appliedPosition.status,
                                          style: TextStyle(
                                            color: _getStatusColor(
                                              appliedPosition.status,
                                            ),
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
    });
  }
}

class ApplicationsPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthRepository());
    Get.put(AppliedPositionsRepository());
    Get.put(JobsRepository());
    Get.put(InternshipsRepository());
    Get.put(
      UserRepository(),
    ); // Corrected from UserRepository if it was a typo before
    Get.put(LoginViewModel());
    Get.put(AppliedPositionsViewModel());
  }
}
