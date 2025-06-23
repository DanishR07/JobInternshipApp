import 'package:final_lab/data/ProfileRepository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/AuthRepository.dart'; // Still needed for Get.put in Binding
import '../../../data/applied_positions_repository.dart';
import '../../../model/Internship.dart'; // Use Internship model
import 'package:final_lab/ui/user_home/internships/view_models/internship_details_vm.dart'; // Use InternshipDetailsViewModel

class InternshipDetailsPage extends StatelessWidget { // Renamed class
  const InternshipDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Internship? internship = Get.arguments; // Changed to Internship
    final InternshipDetailsViewModel internshipDetailsVM = Get.find<InternshipDetailsViewModel>(); // Changed ViewModel

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (internship != null) {
        internshipDetailsVM.checkApplicationStatus(internship);
      }
    });

    if (internship == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: () {
            Get.offAllNamed('/user_home'); // Changed navigation route
          }, icon: const Icon(Icons.arrow_back)),
          title: const Text('Internship Details'), // Updated title
          backgroundColor: Colors.white,
          elevation: 1,
        ),
        body: const Center(
          child: Text('Internship details not found.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Internship Details'), // Updated title
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: internship.image == null || internship.image!.isEmpty // Check for null or empty string
                  ? CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[200],
                child: Icon(Icons.business_center, size: 60, color: Colors.grey[600]), // Changed icon
              )
                  : ClipOval(
                child: Image.network(
                  internship.image!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    child: Icon(Icons.business_center, size: 60, color: Colors.grey[600]), // Changed icon
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              internship.title, // Changed to internship.title
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.business, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Text(
                  internship.companyName, // Changed to internship.companyName
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Text(
                  internship.location,
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_money, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  internship.stipend, // Changed to internship.stipend
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8), // Added for Duration
            Row( // New row for Duration
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey, size: 20), // Changed icon
                const SizedBox(width: 8),
                Text(
                  internship.duration, // Display internship duration
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Internship Description:', // Updated title
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              internship.description,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 32),
            // Conditionally display the "Apply Now" button
            Obx(() {
              if (internshipDetailsVM.hasUserApplied.value) {
                return Center(
                  child: Text(
                    'You have successfully applied for this internship.', // Updated message
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                return Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await internshipDetailsVM.applyForInternship(internship); // Changed method
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Apply Now',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}

class InternshipDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthRepository());
    Get.put(UserRepository());
    Get.put(AppliedPositionsRepository());
    Get.put(InternshipDetailsViewModel());
  }
}