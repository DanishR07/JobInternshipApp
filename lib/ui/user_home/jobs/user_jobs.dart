import 'package:final_lab/data/ProfileRepository.dart';
import 'package:final_lab/data/media_repository.dart';
import 'package:final_lab/ui/job/view_models/jobs_vm.dart';
import 'package:final_lab/ui/profile/view_models/profile_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/AuthRepository.dart';
import '../../../data/jobs_repository.dart';
import '../../../model/Job.dart';
import '../custom_app_bar.dart';
import '../custom_drawer.dart';

class UserJobsPage extends StatefulWidget {
  const UserJobsPage({super.key});

  @override
  State<UserJobsPage> createState() => _UserJobsPageState();
}

class _UserJobsPageState extends State<UserJobsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late JobsViewModel jobsViewModel;
  final AuthRepository authRepository = Get.find();

  @override
  void initState() {
    super.initState();
    jobsViewModel = Get.find<JobsViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        title: 'Jobs', // or any screen name
      ),
      drawer: const CustomDrawer(),

      body: Obx(() {
        if (jobsViewModel.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (jobsViewModel.jobs.isEmpty) {
          return const Center(child: Text('No jobs available.'));
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
                  onTap: () {
                    Get.toNamed('/job_details', arguments: job);
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

class UserJobsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthRepository());
    Get.find<AuthRepository>(); // Just find it, don't put it again
    Get.put(UserRepository());
    Get.put(MediaRepository());
    Get.put(JobsRepository());
    Get.put(ProfileViewModel());
    Get.put(JobsViewModel());
  }
}
