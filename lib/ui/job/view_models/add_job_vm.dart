import 'package:final_lab/data/media_repository.dart';
import 'package:final_lab/model/Job.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/AuthRepository.dart';
import '../../../data/jobs_repository.dart';

class AddJobViewModel extends GetxController {
  AuthRepository authRepository = Get.find();
  JobsRepository jobsRepository = Get.find();
  MediaRepository mediaRepository = Get.find();
  var isSaving = false.obs;

  Rxn<XFile> image = Rxn<XFile>();

  Future<void> addJob(
    String jobtitle,
    String companyname,
    String location,
    String salary,
      String description,
  ) async {
    if (jobtitle.isEmpty) {
      Get.snackbar("Error", "Job Title cannot be empty");
      return;
    }

    if (companyname.isEmpty) {
      Get.snackbar("Error", "Company Name cannot be empty");
      return;
    }

    if (location.isEmpty) {
      Get.snackbar("Error", "Location cannot be empty");
      return;
    }

    if (salary.isEmpty) {
      Get.snackbar("Error", "Salary cannot be empty");
      return;
    }

    if (int.tryParse(salary) == null || int.parse(salary) <= 0) {
      Get.snackbar("Error", "Salary must be in digit and greater than 0");
      return;
    }
    if (description.isEmpty) {
      Get.snackbar("Error", "Description cannot be empty");
      return;
    }

    isSaving.value = true;

      Job job = Job(
        '',
        authRepository
            .getLoggedInUser()
            ?.uid ?? '',
        jobtitle,
        companyname,
        location,
        salary,
        description,
      );


      if (image.value != null) {
        var imageResult = await mediaRepository.uploadImage(image.value!.path);
        if (imageResult.isSuccessful) {
          job.image = imageResult.url;
        } else {
          Get.snackbar(
            "Error uploading image",
            imageResult.error ?? "An error occurred while uploading image",
          );
          return;
        }
      }
      try {
        await jobsRepository.addJob(job);
        Get.back(result: true);
      } catch (e) {
        Get.snackbar(
          "Error",
          "An error occurred while adding job: ${e.toString()}",
        );
      }
      isSaving.value = false;

  }
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    image.value = await picker.pickImage(source: ImageSource.gallery);
  }
}
