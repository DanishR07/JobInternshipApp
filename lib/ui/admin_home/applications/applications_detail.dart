// lib/ui/applied_positions/application_detail_page.dart
import 'package:final_lab/data/ProfileRepository.dart'; // This should be UserRepository as per your binding
import 'package:final_lab/ui/admin_home/applications/view_model/application_detail_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:cached_network_image/cached_network_image.dart'; // For applicant profile image
import 'package:url_launcher/url_launcher.dart';

import '../../../data/applied_positions_repository.dart';
import '../../../data/internships_repository.dart';
import '../../../data/jobs_repository.dart';
import '../../../data/notification_repository.dart';
import '../../../model/Internship.dart';
import '../../../model/Job.dart';


class ApplicationDetailPage extends GetView<ApplicationDetailViewModel> {
  const ApplicationDetailPage({super.key});

  // Helper method to get color based on status (re-using from ApplicationsPage)
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

  // Helper to build profile rows for the applicant's data
  Widget _buildProfileDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.appliedPosition.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final appliedPosition = controller.appliedPosition.value;
        final positionDetails = controller.positionDetails.value;
        final applicantProfile = controller.applicantProfile.value;

        if (appliedPosition == null) {
          return const Center(child: Text('No application data found.'));
        }

        // Extracting details for the top card display
        String title = 'N/A';
        String companyName = 'N/A';
        String salaryStipend = '';
        IconData positionIcon = Icons.help_outline;
        Widget imageWidget = const Icon(Icons.business, size: 40, color: Colors.grey);

        if (positionDetails != null) {
          if (appliedPosition.positionType == 'job') {
            Job job = positionDetails as Job;
            title = job.jobtitle;
            companyName = job.companyname;
            salaryStipend = 'Salary: ${job.salary}';
            positionIcon = Icons.work;
            if (job.image != null && job.image!.isNotEmpty) {
              imageWidget = ClipOval(
                child: CachedNetworkImage(
                  imageUrl: job.image!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.business, size: 40, color: Colors.grey),
                ),
              );
            }
          } else { // internship
            Internship internship = positionDetails as Internship;
            title = internship.title;
            companyName = internship.companyName;
            salaryStipend = 'Stipend: ${internship.stipend} (${internship.duration})';
            positionIcon = Icons.lightbulb;
            if (internship.image != null && internship.image!.isNotEmpty) {
              imageWidget = ClipOval(
                child: CachedNetworkImage(
                  imageUrl: internship.image!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.business_center, size: 40, color: Colors.grey),
                ),
              );
            }
          }
        } else {
          title = 'Position Details Not Found';
          companyName = 'N/A';
          salaryStipend = '';
          positionIcon = Icons.info_outline;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Display the original applied position card ---
              Card(
                margin: EdgeInsets.zero, // No external margin, padding is internal
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          imageWidget,
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  companyName,
                                  style: TextStyle(fontSize: 17, color: Colors.grey[700]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),
                                Chip(
                                  avatar: Icon(
                                    positionIcon,
                                    size: 14,
                                    color: appliedPosition.positionType == 'job'
                                        ? Colors.deepPurple
                                        : Colors.teal,
                                  ),
                                  label: Text(
                                    appliedPosition.positionType == 'job' ? 'Job' : 'Internship',
                                    style: TextStyle(
                                      fontSize: 13,
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
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: appliedPosition.positionType == 'job'
                                          ? Colors.deepPurple[200]!
                                          : Colors.teal[200]!,
                                      width: 0.8,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 30, thickness: 1.2),
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
                                  style: TextStyle(fontSize: 13, color: Colors.grey),
                                ),
                                Text(
                                  DateFormat('MMM dd, yyyy (EEE)').format(appliedPosition.appliedDate),
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  salaryStipend,
                                  style: const TextStyle(fontSize: 15, color: Colors.green, fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Current Status:',
                                style: TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(appliedPosition.status).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  appliedPosition.status,
                                  style: TextStyle(
                                    color: _getStatusColor(appliedPosition.status),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
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

              const SizedBox(height: 25),

              // --- Applicant's Profile ---
              Text(
                'Applicant Profile',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              applicantProfile == null
                  ? const Center(child: Text("This user has deleted his account.\nSo unable to fetch user's profile",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),))
                  : Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: applicantProfile.image != null && applicantProfile.image!.isNotEmpty
                            ? CachedNetworkImageProvider(applicantProfile.image!) as ImageProvider
                            : null,
                        child: applicantProfile.image == null || applicantProfile.image!.isEmpty
                            ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                            : null,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        '${applicantProfile.firstName} ${applicantProfile.lastName}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        applicantProfile.email,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const Divider(height: 25, thickness: 0.8),
                      _buildProfileDetailRow('Phone', applicantProfile.phoneNumber),
                      if (applicantProfile.resume != null && applicantProfile.resume!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Resume',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey),
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                                label: const Text(
                                  'View Resume',
                                  style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                ),
                                onPressed: () async {
                                  if (await canLaunchUrl(Uri.parse(applicantProfile.resume!))) {
                                    await launchUrl(Uri.parse(applicantProfile.resume!));
                                  } else {
                                    Get.snackbar('Error', 'Could not open resume.', snackPosition: SnackPosition.BOTTOM);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // --- Admin Status Change Options ---
              // THIS SECTION HAS BEEN REFINED
              Card(
                elevation: 5, // Slightly higher elevation for prominence
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                clipBehavior: Clip.antiAlias, // Ensures content respects border radius
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Header with Title
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                      decoration: const BoxDecoration(
                        color: Colors.blueAccent, // A distinct header color
                        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                      ),
                      child: Text(
                        'Manage Application Status',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0), // Padding for the content inside the card
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select the new status for this application:',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                          ),
                          const SizedBox(height: 15), // Increased spacing
                          Obx(() => DropdownButtonFormField<String>(
                            value: controller.currentStatus.value.isEmpty ? null : controller.currentStatus.value,
                            decoration: InputDecoration(
                              labelText: 'Application Status', // Label for clarity
                              labelStyle: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w500),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12), // Rounded corners
                                borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.7)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.5), width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            ),
                            hint: const Text('Choose Status'),
                            onChanged: controller.setSelectedStatus,
                            items: <String>['Pending', 'Reviewed', 'Accepted', 'Rejected']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Container(
                                  // Add a subtle background for the selected item in the dropdown list
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: controller.currentStatus.value == value
                                        ? Colors.blueAccent.withOpacity(0.1)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      color: _getStatusColor(value), // Color based on status
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          )),
                          const SizedBox(height: 30), // Increased spacing before the button
                          SizedBox(
                            width: double.infinity,
                            child: Obx(() => ElevatedButton.icon(
                              onPressed: controller.isLoading.value ? null : controller.updateApplicationStatus,
                              icon: controller.isLoading.value
                                  ? const SizedBox(
                                width: 22, // Slightly larger spinner
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                              )
                                  : const Icon(Icons.save, color: Colors.white, size: 24), // Larger icon
                              label: Text(
                                controller.isLoading.value ? 'Saving Changes...' : 'Save Application Status', // More descriptive
                                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent, // Consistent with header
                                foregroundColor: Colors.white, // Text color for button
                                padding: const EdgeInsets.symmetric(vertical: 14), // More vertical padding
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
                                elevation: 5, // More prominent shadow
                                shadowColor: Colors.blueAccent.withOpacity(0.4), // Subtle shadow color
                              ),
                            )),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// Ensure the binding reflects the correct repository name (ProfileRepository vs UserRepository)
class ApplicationDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AppliedPositionsRepository());
    Get.put(JobsRepository());
    Get.put(InternshipsRepository());
    // CRUCIAL: Use UserRepository if that's the correct name of your profile repository
    Get.put(UserRepository()); // Assuming ProfileRepository was renamed to UserRepository
    // Get.put(LoginViewModel()); // Only put this if LoginViewModel is specifically needed by ApplicationDetailViewModel
    // Otherwise, it's good practice to remove unused dependencies.
    Get.put(NotificationRepository());
    Get.put(ApplicationDetailViewModel());
  }
}