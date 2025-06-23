import 'package:final_lab/data/ProfileRepository.dart';
import 'package:final_lab/data/applied_positions_repository.dart';
import 'package:final_lab/ui/user_home/jobs/view_models/job_details_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/AuthRepository.dart';
import '../../../model/Job.dart';

class JobDetailsPage extends StatelessWidget {
  const JobDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Job? job = Get.arguments;
    final JobDetailsViewModel jobDetailsVM = Get.find<JobDetailsViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (job != null) {
        jobDetailsVM.checkApplicationStatus(job);
      }
    });


    if (job == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: () {
            Get.offAllNamed('/user_home');
          }, icon: Icon(Icons.arrow_back)),
          title: const Text('Job Details'),
          backgroundColor: Colors.white,
          elevation: 1,
        ),
        body: const Center(
          child: Text('Job details not found.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: job.image == null
                  ? CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[200],
                child: Icon(Icons.business, size: 60, color: Colors.grey[600]),
              )
                  : ClipOval(
                child: Image.network(
                  job.image!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    child: Icon(Icons.business, size: 60, color: Colors.grey[600]),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              job.jobtitle,
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
                  job.companyname,
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
                  job.location,
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
                  job.salary,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Job Description:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              job.description,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 32),
            // Conditionally display the "Apply Now" button
            Obx(() {
              if (jobDetailsVM.hasUserApplied.value) {
                return Center(
                  child: Text(
                    'You have successfully applied for this job.',
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
                      await jobDetailsVM.applyForJob(job);
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

class JobDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthRepository());
    Get.put(AppliedPositionsRepository());
    Get.put(UserRepository());
    Get.put(JobDetailsViewModel());
  }
}