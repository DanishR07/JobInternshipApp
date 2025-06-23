import 'dart:io';

import 'package:final_lab/ui/job/view_models/edit_job_vm.dart';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../data/AuthRepository.dart';

import '../../data/jobs_repository.dart';

import '../../data/media_repository.dart';
import '../../model/Job.dart';

class EditJob extends StatefulWidget {
  const EditJob({super.key});

  @override
  State<EditJob> createState() => _EditJobState();
}

class _EditJobState extends State<EditJob> {
  TextEditingController jobtitleController = TextEditingController();
  TextEditingController companynameController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController salaryController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  late EditJobViewModel editJobVM;

  late Job job;

  @override
  void initState() {
    super.initState();
    editJobVM = Get.find<EditJobViewModel>();

    job = Get.arguments;

    if (job != null) {
      jobtitleController = TextEditingController(text: job!.jobtitle);
      companynameController = TextEditingController(text: job!.companyname);
      locationController = TextEditingController(text: job!.location);
      salaryController = TextEditingController(text: job!.salary.toString());
      descriptionController = TextEditingController(text: job!.description);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,

        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Get.offAllNamed('/jobs');
          },
          icon: Icon(Icons.arrow_back),
        ),

        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,

                  child: const Text(
                    "Edit Job",

                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Obx(
                () =>
                    editJobVM.image.value == null
                        ? Icon(Icons.image, size: 80)
                        : Image.file(
                          File(editJobVM.image.value!.path),
                          width: 80,
                          height: 80,
                        ),
              ),

              ElevatedButton(
                onPressed: () {
                  editJobVM.pickImage();
                },
                child: Text('Pick Image'),
              ),

              //job title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8F9),

                    border: Border.all(color: const Color(0xFFE8ECF4)),

                    borderRadius: BorderRadius.circular(8),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),

                    child: TextFormField(
                      controller: jobtitleController,

                      decoration: const InputDecoration(
                        border: InputBorder.none,

                        hintText: 'Enter job title',

                        hintStyle: TextStyle(color: Color(0xFF8391A1)),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              //company name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8F9),

                    border: Border.all(color: const Color(0xFFE8ECF4)),

                    borderRadius: BorderRadius.circular(8),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),

                    child: TextFormField(
                      controller: companynameController,

                      decoration: InputDecoration(
                        border: InputBorder.none,

                        hintText: 'Enter company name',

                        hintStyle: const TextStyle(color: Color(0xFF8391A1)),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              //location
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8F9),

                    border: Border.all(color: const Color(0xFFE8ECF4)),

                    borderRadius: BorderRadius.circular(8),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),

                    child: TextFormField(
                      controller: locationController,

                      decoration: const InputDecoration(
                        border: InputBorder.none,

                        hintText: 'Enter location',

                        hintStyle: TextStyle(color: Color(0xFF8391A1)),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              //salary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8F9),

                    border: Border.all(color: const Color(0xFFE8ECF4)),

                    borderRadius: BorderRadius.circular(8),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),

                    child: TextFormField(
                      controller: salaryController,

                      keyboardType: TextInputType.number,

                      decoration: const InputDecoration(
                        border: InputBorder.none,

                        hintText: 'Enter salary',

                        hintStyle: TextStyle(color: Color(0xFF8391A1)),
                      ),
                    ),
                  ),
                ),
              ),

              //description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8F9),
                    border: Border.all(color: const Color(0xFFE8ECF4)),
                    borderRadius: BorderRadius.circular(8),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),

                    child: TextFormField(
                      controller: descriptionController,

                      decoration: const InputDecoration(
                        border: InputBorder.none,

                        hintText: 'Enter description',

                        hintStyle: TextStyle(color: Color(0xFF8391A1)),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              //save button
              Obx(() {
                return editJobVM.isUpdating.value
                    ? CircularProgressIndicator()
                    : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,

                        vertical: 5,
                      ),

                      child: Row(
                        children: [
                          Expanded(
                            child: MaterialButton(
                              color: const Color(0xFF1E232C),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),

                              onPressed: () {
                                if (job != null) {
                                  editJobVM.updateJob(
                                    job,
                                    jobtitleController.text,
                                    companynameController.text,
                                    locationController.text,
                                    salaryController.text,
                                    descriptionController.text,
                                  );
                                }
                              },

                              child: const Padding(
                                padding: EdgeInsets.all(15.0),

                                child: Text(
                                  "Update",

                                  style: TextStyle(
                                    color: Colors.white,

                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class UpdateJobBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthRepository());
    Get.put(JobsRepository());
    Get.put(MediaRepository());
    Get.put(EditJobViewModel());
  }
}
