import 'dart:io';
import 'package:final_lab/ui/job/view_models/add_job_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/AuthRepository.dart';
import '../../data/jobs_repository.dart';
import '../../data/media_repository.dart';

class AddJob extends StatefulWidget {
  const AddJob({super.key});

  @override
  State<AddJob> createState() => _AddJobState();
}

class _AddJobState extends State<AddJob> {
  TextEditingController jobtitleController = TextEditingController();
  TextEditingController companynameController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController salaryController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  late AddJobViewModel addjobVM;

  @override
  void initState() {
    super.initState();
    addjobVM = Get.find<AddJobViewModel>();
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
                    "Add Job",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Obx(
                () =>
                    addjobVM.image.value == null
                        ? Icon(Icons.image, size: 80)
                        : Image.file(
                          File(addjobVM.image.value!.path),
                          width: 800,
                          height: 80,
                        ),
              ),

              ElevatedButton(
                onPressed: () {
                  addjobVM.pickImage();
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

              const SizedBox(height: 15),
              //description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 200,
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
                return addjobVM.isSaving.value
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
                                addjobVM.addJob(
                                  jobtitleController.text,
                                  companynameController.text,
                                  locationController.text,
                                  salaryController.text,
                                  descriptionController.text,
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(15.0),

                                child: Text(
                                  "Save",

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

class AddJobBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthRepository());
    Get.put(JobsRepository());
    Get.put(MediaRepository());
    Get.put(AddJobViewModel());
  }
}
