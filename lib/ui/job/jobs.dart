import 'package:final_lab/ui/job/view_models/jobs_vm.dart';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../data/AuthRepository.dart';

import '../../data/jobs_repository.dart';

import '../../model/Job.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  late JobsViewModel jobsViewModel;
  final AuthRepository authRepository = Get.find();

  @override
  void initState() {
    super.initState();
    jobsViewModel = Get.find<JobsViewModel>();
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

  @override
  Widget build(BuildContext context) {
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
                'Job Listings',

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

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var result = await Get.toNamed('/add_job');
          if (result == true) {
            Get.snackbar("Success", "Job added successfully");
          }
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        if (jobsViewModel.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (jobsViewModel.jobs.isEmpty) {
          return const Center(
            child: Text('No jobs available. Click the + button to add one.'),
          );
        } else {
          return ListView.separated(
            padding: const EdgeInsets.all(10),

            itemCount: jobsViewModel.jobs.length,

            separatorBuilder: (context, index) => const SizedBox(height: 10),

            itemBuilder: (context, index) {
              Job job = jobsViewModel.jobs[index];

              return Card(
                elevation: 3,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),

                child: InkWell(
                  onLongPress: () {
                    Get.dialog(
                      AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            TextButton.icon(
                              onPressed: () {
                                Get.back();

                                Get.toNamed('/edit_job', arguments: job);
                              },

                              icon: const Icon(Icons.edit),

                              label: const Text('Edit'),
                            ),

                            const Divider(),

                            TextButton.icon(
                              onPressed: () {
                                Get.back();
                                jobsViewModel.deleteJob(job);
                              },

                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),

                              label: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },

                  child: Padding(
                    padding: const EdgeInsets.all(16.0),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        job.image == null
                            ? const Icon(Icons.image, size: 80)
                            : ClipOval(
                              child: Image.network(
                                job.image!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),

                        Text(
                          job.jobtitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.business,
                              color: Colors.grey,
                              size: 16,
                            ),

                            const SizedBox(width: 5),
                            Text(
                              job.companyname,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              job.location,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(
                              Icons.attach_money,
                              color: Colors.green,
                              size: 16,
                            ),

                            const SizedBox(width: 5),

                            Text(
                              job.salary,

                              style: const TextStyle(
                                color: Colors.green,

                                fontWeight: FontWeight.w500,
                              ),
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
        }
      }),
    );
  }
}

class JobsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthRepository());
    Get.put(JobsRepository());
    Get.put(JobsViewModel());
  }
}
