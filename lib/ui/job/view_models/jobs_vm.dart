import 'package:get/get.dart';

import 'package:get/get_core/src/get_main.dart';
import '../../../data/AuthRepository.dart';

import '../../../data/jobs_repository.dart';

import '../../../model/Job.dart';

class JobsViewModel extends GetxController {
  AuthRepository authRepository = Get.find();

  JobsRepository jobsRepository = Get.find();

  var isLoading = false.obs;

  var jobs = <Job>[].obs;

  @override
  void onInit() {
    super.onInit();

    loadAllJobs();
  }

  void loadAllJobs() {
    jobsRepository.loadAllJobs().listen((data) {
      jobs.value = data;
    });
  }

  Future<void> deleteJob(Job job) async {
    await jobsRepository.deleteJob(job);
  }
}
